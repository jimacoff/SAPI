class Admin::ListingChangesController < Admin::SimpleCrudController
  belongs_to :eu_regulation


  protected
  def collection
    @listing_changes ||= end_of_association_chain.
      includes([
        :species_listing,
        :change_type,
        :party_geo_entity,
        :geo_entities,
        :annotation,
        :taxon_concept,
        :exclusions => [:geo_entities, :taxon_concept]
      ]).
      where("change_types.name <> '#{ChangeType::EXCEPTION}'").
      order('taxon_concepts.full_name ASC').
      page(params[:page]).per(200).where(:parent_id => nil)
  end
end
