class Admin::TaxonConceptsController < Admin::SimpleCrudController
  respond_to :json
  inherit_resources

  def index
    @designations = Designation.order(:name)
    @ranks = Rank.order(:name)
    index!
  end

  def create
    @designations = Designation.order(:name)
    @ranks = Rank.order(:name)
    super
  end

  def autocomplete
    @taxon_concepts = TaxonConcept.
      select("data, #{TaxonConcept.table_name}.id, #{Designation.table_name}.name AS designation_name").
      joins(:designation)
    if params[:scientific_name]
      @taxon_concepts = @taxon_concepts.by_scientific_name(params[:scientific_name])
    end
    if params[:designation_id]
      @taxon_concepts = @taxon_concepts.where(:designation_id => params[:designation_id])
    end
    if params[:rank_id]
      @taxon_concepts = @taxon_concepts.where(:rank_id => Rank.scoped.above_rank(params[:rank_id]).map(&:id))
    end
    render :json => @taxon_concepts.to_json(:only => [:id, :designation_name], :methods => [:rank_name, :full_name])#map{ |tc| tc.attributes.slice(:full_name, :rank_name, :id) }
  end

  protected
    def collection
      @taxon_concepts ||= end_of_association_chain.
        includes([:rank, :designation, :taxon_name, :parent]).
        order("data->'taxonomic_position'").page(params[:page])
    end
end
