class Admin::SynonymRelationshipsController < Admin::TaxonConceptAssociatedTypesController
  defaults :resource_class => TaxonRelationship, :collection_name => 'synonym_relationships', :instance_name => 'synonym_relationship'
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept
  before_filter :load_synonym_relationship_type, :only => [:new, :create, :update]

  def new
    new! do |format|
      load_taxonomies_and_ranks
      @synonym_relationship = TaxonRelationship.new(
        :taxon_relationship_type_id => @synonym_relationship_type.id
      )
      @synonym_relationship.build_other_taxon_concept(
        :taxonomy_id => @taxon_concept.taxonomy_id,
        :rank_id => @taxon_concept.rank_id,
        :name_status => 'S'
      )
      @synonym_relationship.other_taxon_concept.build_taxon_name
    end
  end

  def create
    params[:taxon_relationship][:taxon_relationship_type_id] =
      @synonym_relationship_type.id
    create! do |success, failure|
      success.js {
        @synonym_relationships = @taxon_concept.synonym_relationships.
          includes(:other_taxon_concept).order('taxon_concepts.full_name')
        render 'create'
      }
      failure.js {
        @synonym_relationship.build_other_taxon_concept(
          :taxonomy_id => @taxon_concept.taxonomy_id,
          :rank_id => @taxon_concept.rank_id,
          :name_status => 'S',
          :full_name => params[:taxon_relationship][:other_taxon_concept_attributes][:full_name],
          :author_year => params[:taxon_relationship][:other_taxon_concept_attributes][:author_year]

        )
        @synonym_relationship.other_taxon_concept.build_taxon_name
        load_taxonomies_and_ranks
        render 'new'
      }
    end
  end

  def edit
    edit! do |format|
      load_taxonomies_and_ranks
      format.js { render 'new' }
    end
  end

  def update
    params[:taxon_relationship][:taxon_relationship_type_id] =
      @synonym_relationship_type.id
    update! do |success, failure|
      success.js {
        @synonym_relationships = @taxon_concept.synonym_relationships.
          includes(:other_taxon_concept).order('taxon_concepts.full_name')
        render 'create'
      }
      failure.js {
        load_taxonomies_and_ranks
        render 'new'
      }
    end
  end

  def destroy
    destroy! do |success|
      success.html {
        redirect_to admin_taxon_concept_names_path(@taxon_concept)
      }
    end
  end

  protected

  def load_taxonomies_and_ranks
    @taxonomies = Taxonomy.order(:name)
    @ranks = Rank.order(:taxonomic_position)
  end

  def load_synonym_relationship_type
    @synonym_relationship_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)
  end

end

