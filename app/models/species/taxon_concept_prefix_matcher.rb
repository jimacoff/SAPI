class Species::TaxonConceptPrefixMatcher
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt

  def initialize(options)
    initialize_options(options)
    initialize_query
  end

  def results
    (@taxon_concept_query || !@ranks.empty?) &&
    @query.limit(@options[:per_page]).
      offset(@options[:per_page] * (@options[:page] - 1)).all || []
  end

  def total_cnt
    (@taxon_concept_query || !@ranks.empty?) && @query.count || 0
  end

  private

  def initialize_options(options)
    @options = Species::SearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
  end

  def initialize_query
    @query = MAutoCompleteTaxonConcept.order([:rank_order, :full_name])
    unless @ranks.empty?
      @query = @query.where(:rank_name => @ranks)
    end

    @query = if @taxonomy == :cms
      @query.by_cms_taxonomy
    else
      @query.by_cites_eu_taxonomy
    end

    @query = if @visibility == :trade_internal
       @query # no filter on name_status for internal search
    elsif @visibility == :trade
      @query.where(:show_in_trade_ac => true)
    else
      @query.where(:show_in_species_plus_ac => true)
    end

    if @taxon_concept_query
      @query = @query.
        select('id, full_name, rank_name,
          ARRAY_AGG_NOTNULL(
            CASE WHEN matched_name != full_name THEN matched_name ELSE NULL END
            ORDER BY matched_name
          ) AS matching_names_ary').
      where(
        ActiveRecord::Base.send(:sanitize_sql_array, [
          "name_for_matching LIKE :sci_name_prefix",
          :sci_name_prefix => "#{@taxon_concept_query}%"
        ])
      ).group([:id, :full_name, :rank_name, :rank_order])
    end
    @query
  end

end

