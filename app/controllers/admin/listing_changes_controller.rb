class Admin::ListingChangesController < Admin::SimpleCrudController

  belongs_to :taxon_concept, :designation, :optional => true
  #before_filter :load_change_types, :only => [:index, :create]
  layout 'taxon_concepts'

  def index
    index! do
      load_change_types
    end
  end

  def create
    params[:listing_change][:geo_entity_ids] &&
      params[:listing_change][:geo_entity_ids].delete("")
    @listing_change = ListingChange.new(params[:listing_change])
    create! do
      load_change_types
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation),
        :notice => 'Operation successful'
      }
    end
  end

  protected
  def load_change_types
    @taxon_concept ||= TaxonConcept.find(params[:taxon_concept_id])
    @change_types = ChangeType.order(:name).
      where(:designation_id => @designation.id)
    @species_listings = SpeciesListing.order(:abbreviation).
      where(:designation_id => @designation.id)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
    @listing_change = ListingChange.new(:taxon_concept_id => @taxon_concept.id)
    @listing_change.listing_distributions.build
  end

  def collection
    @listing_changes ||= end_of_association_chain.
      order('effective_at desc, is_current desc').
      page(params[:page]).where(:parent_id => nil)
  end
end
