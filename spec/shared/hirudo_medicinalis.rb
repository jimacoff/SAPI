shared_context "Hirudo medicinalis" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Hirudinoidea').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Arhynchobdellida'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Hirudinidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Hirudo'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Medicinalis'),
      :parent => @genus
    )

    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1987-10-22'
    )

    Sapi::fix_listing_changes
    Sapi::rebuild
    self.instance_variables.each do |t|
      self.instance_variable_get(t).reload
    end

  end

end