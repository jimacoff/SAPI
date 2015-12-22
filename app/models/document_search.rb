class DocumentSearch
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt
  attr_reader :page, :per_page, :offset, :event_type, :event_id,
    :document_type, :title_query

  def initialize(options, interface)
    @interface = interface
    initialize_params(options)
    initialize_query
  end

  def results
    if admin_interface?
      results = @query.limit(@per_page).
        offset(@offset)
    else
      results = select_and_group_query
    end
  end

  def total_cnt
    @query.count
  end

  def taxon_concepts
    @taxon_concepts ||= TaxonConcept.where(id: @taxon_concepts_ids)
  end

  def geo_entities
    @geo_entities ||= GeoEntity.where(id: @geo_entities_ids)
  end

  def document_tags
    @document_tags ||= DocumentTag.where(id: @document_tags_ids)
  end

  private

  def admin_interface?
    @interface == 'admin'
  end

  def table_name
    admin_interface? ? 'documents_view' : 'api_documents_mview'
  end

  def initialize_params(options)
    @options = DocumentSearchParams.sanitize(options)
    @options[:show_private] = true if admin_interface?
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    @offset = @per_page * (@page - 1)
  end

  def initialize_query
    @query = Document.from("#{table_name} documents")
    @query = @query.where(is_public: true) if !admin_interface? && !@show_private
    add_conditions_for_event
    add_conditions_for_document
    add_extra_conditions
    if admin_interface?
      add_ordering_for_admin
    else
      add_ordering_for_public
    end
  end

  def add_conditions_for_event
    return unless @event_id || @event_type
    if @event_id.present?
      @query = @query.where(event_id: @event_id)
    elsif @event_type.present?
      @query = @query.where(event_type: @event_type)
    end
  end

  def add_conditions_for_document
    @query = @query.search_by_title(@title_query) if @title_query.present?

    if @document_type.present?
      @query = if admin_interface?
        @query.where('documents.type' => @document_type)
      else
        @query.where('document_type' => @document_type)
      end
    end

    if admin_interface?
      if !@document_date_start.blank?
        @query = @query.where("documents.date >= ?", @document_date_start)
      end
      if !@document_date_end.blank?
        @query = @query.where("documents.date <= ?", @document_date_end)
      end
    end
  end

  def add_extra_conditions
    add_taxon_concepts_condition if @taxon_concepts_ids.present?
    add_geo_entities_condition if @geo_entities_ids.present?
    add_document_tags_condition if @document_tags_ids.present?
  end

  def add_taxon_concepts_condition
    @query = @query.where(
      "taxon_concept_ids && ARRAY[#{@taxon_concepts_ids.join(',')}]"
    )
  end

  def add_geo_entities_condition
    @query = @query.where("geo_entity_ids && ARRAY[#{@geo_entities_ids.join(',')}]")
  end

  def add_document_tags_condition
    @query = @query.where("document_tags_ids && ARRAY[#{@document_tags_ids.join(',')}]")
  end

  def add_ordering_for_admin
    return if @title_query.present?

    @query = if @event_id.present?
      @query.order([:date, :title])
    else
      @query.order('created_at DESC')
    end
  end

  def add_ordering_for_public
    @query.order('date_raw DESC')
  end

  def select_and_group_query
    columns = "event_name, event_type, date, date_raw, is_public, document_type,
      proposal_number, primary_document_id,
      geo_entity_names, taxon_names, extension,
      proposal_outcome, review_phase"
    aggregators = <<-SQL
      ARRAY_TO_JSON(
        ARRAY_AGG_NOTNULL(
          ROW(
            documents.id,
            documents.title,
            documents.language
          )::document_language_version
        )
      ) AS document_language_versions
    SQL

    @query = Document.from(
      '(' + @query.to_sql + ') documents'
    ).select(columns + "," + aggregators).group(columns)
  end

  def self.refresh
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW api_documents_mview')
  end

end
