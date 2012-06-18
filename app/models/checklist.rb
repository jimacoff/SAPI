class Checklist
  attr_accessor :taxon_concepts_rel
  def initialize(options)
    @taxon_concepts_rel = TaxonConcept.scoped.
      select([:"taxon_concepts.id", :data, :listing])
    @designation = options[:designation] || Designation::CITES
    @taxon_concepts_rel = @taxon_concepts_rel.
      joins(:designation).
      where('designations.name' => @designation)
    #limit to the level of listing
    @level_of_listing = options[:level_of_listing] || false
    #TODO
    #filter by geo entities
    @geo_options = []
    @geo_options += options[:country_ids] unless options[:country_ids].nil?
    @geo_options += options[:cites_region_ids] unless options[:cites_region_ids].nil?
    unless @geo_options.empty?
      @taxon_concepts_rel = @taxon_concepts_rel.by_geo_entities(@geo_options)
    end
    #filter by higher taxa
    @higher_taxa = options[:higher_taxon_ids] || nil
    #possible output layouts are:
    #taxonomic (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :alphabetical
  end

  def generate
    if @output_layout == :taxonomic
      @taxon_concepts = @taxon_concepts_rel.
        where("data -> 'rank_name' <> 'GENUS'").#TODO verify if joining with ranks would be faster
        order("data -> 'taxonomic_position'")
    else
      @taxon_concepts = @taxon_concepts_rel.
        where("data -> 'rank_name' IN (?)", [Rank::GENUS, Rank::SPECIES, Rank::SUBSPECIES]).
        order("data -> 'full_name'")
    end
  end

end
