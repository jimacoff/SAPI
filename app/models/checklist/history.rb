class Checklist::History < Checklist::Checklist
  attr_reader :download_name

  def initialize(options={})
    options = {
      :output_layout => :taxononomic,
      :show_english => true,
      :show_french => true,
      :show_spanish => true
    }
    # History cannot be parametrized like other Checklist reports
    @download_path = download_location(options, "history", ext)

    # If a cached download exists, only initialize the params for the
    # helper methods, otherwise initialize the generation queries.

    if !File.exists?(@download_path)
      super(options)
    else
      initialize_params(options)
    end
  end

  def has_full_options?
    true
  end

  def prepare_kingdom_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_position = 0")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_position = 1")
  end

  def prepare_main_query
    cites = Designation.find_by_name(Designation::CITES)
    @taxon_concepts_rel = MTaxonConcept.where(:taxonomy_is_cites_eu => true).
      where(
        <<-SQL
        EXISTS (
          SELECT * FROM listing_changes_mview
          WHERE taxon_concept_id = taxon_concepts_mview.id 
          AND show_in_downloads
          AND designation_id = #{cites.id}
        )
        SQL
      ).
      order(:taxonomic_position)
  end

  def generate
    if !File.exists?(@download_path)
      prepare_queries
      document do |doc|
        content(doc)
      end
    end
    ctime = File.ctime(@download_path).strftime('%Y-%m-%d %H:%M')
    @download_name = "History_of_CITES_Listings_#{has_full_options? ? '' : '[CUSTOM]_'}#{ctime}.#{ext}"
    @download_path
  end

end
