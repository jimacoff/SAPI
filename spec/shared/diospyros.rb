shared_context "Diospyros" do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:madagascar){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Madagascar',
      :iso_code2 => 'MG'
    )
  }
  let(:sri_lanka){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Sri Lanka',
      :iso_code2 => 'LK'
    )
  }
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Ebenales'),
      :parent => cites_eu_plantae.reload # reload is needed for full name
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Ebenaceae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Diospyros'),
      :parent => @family
    )
    @species1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'aculeata'),
      :parent => @genus
    )
    @species2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'acuta'),
      :parent => @genus
    )

    create(
      :distribution,
      :taxon_concept_id => @species1.id,
      :geo_entity_id => madagascar.id
    )

    create(
      :distribution,
      :taxon_concept_id => @species2.id,
      :geo_entity_id => sri_lanka.id
    )

    cites_lc = create_cites_III_addition(
     :taxon_concept => @species1,
     :effective_at => '2011-12-22',
     :is_current => false
    )

    create(
      :listing_distribution,
      :listing_change => cites_lc,
      :geo_entity => madagascar,
      :is_party => true
    )

    eu_lc = create_eu_C_addition(
     :taxon_concept => @species1,
     :effective_at => '2012-12-15',
     :event => reg2012,
     :is_current => false
    )

    create(
      :listing_distribution,
      :listing_change => eu_lc,
      :geo_entity => madagascar,
      :is_party => true
    )

    cites_lc = create_cites_III_deletion(
     :taxon_concept => @species1,
     :effective_at => '2013-06-12',
     :is_current => false
    )

    create(
      :listing_distribution,
      :listing_change => cites_lc,
      :geo_entity => madagascar,
      :is_party => true
    )

    cites_lc = create_cites_II_addition(
     :taxon_concept => @genus,
     :effective_at => '2013-06-12',
     :is_current => true
    )

    create(
      :listing_distribution,
      :listing_change => cites_lc,
      :geo_entity => madagascar,
      :is_party => false
    )

    create_cites_II_addition(
     :taxon_concept => @species1,
     :effective_at => '2013-06-12',
     :inclusion_taxon_concept_id => @genus.id,
     :is_current => true
    )

    eu_lc = create_eu_B_addition(
     :taxon_concept => @genus,
     :effective_at => '2013-08-10',
     :event => reg2013,
     :is_current => true
    )

    create(
      :listing_distribution,
      :listing_change => eu_lc,
      :geo_entity => madagascar,
      :is_party => false
    )

    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    Sapi::StoredProcedures.rebuild_eu_taxonomy_and_listings
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
