require 'spec_helper'

describe Admin::EuSuspensionsController do
  before do
    @taxon_concept = create(:taxon_concept)
  end

  describe "GET index" do
    it "renders the index template" do
      get :index, :taxon_concept_id => @taxon_concept.id
      response.should render_template("index")
    end
    it "renders the taxon_concepts_layout" do
      get :index, :taxon_concept_id => @taxon_concept.id
      response.should render_template('layouts/taxon_concepts')
    end
  end

  describe "GET new" do
    it "renders the new template" do
      get :new, :taxon_concept_id => @taxon_concept.id
      response.should render_template('new')
    end
  end

  describe "POST create" do
    context "when successful" do
      it "redirects to the EU suspensions index" do
        post :create, :eu_suspension => {
            :restriction => EuDecision::RESTRICTION_TYPES.first,
            :start_date => Date.new(2013,1,1)
          },
          :taxon_concept_id => @taxon_concept.id
          response.should redirect_to(admin_taxon_concept_eu_suspensions_url(@taxon_concept.id))
      end
    end

    context "when not successful" do
      it "renders new" do
        post :create, :eu_suspension => {},
          :taxon_concept_id => @taxon_concept.id
        response.should render_template("new")
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @eu_suspension = create(
        :eu_suspension,
        :taxon_concept_id => @taxon_concept.id
      )
    end
    it "renders the edit template" do
      get :edit, :id => @eu_suspension.id, :taxon_concept_id => @taxon_concept.id
      response.should render_template('edit')
    end
  end

  describe "PUT update" do
    before(:each) do
      @eu_suspension = create(
        :eu_suspension,
        :taxon_concept_id => @taxon_concept.id
      )
    end

    context "when successful" do
      it "renders taxon_concepts EU suspensions page" do
        put :update, :eu_suspension => {
            :restriction => EuDecision::RESTRICTION_TYPES.last
          },
          :id => @eu_suspension.id,
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_eu_suspensions_url(@taxon_concept)
        )
      end
    end

    context "when not successful" do
      it "renders new" do
        put :update, :eu_suspension => {
            :restriction => nil
          },
          :id => @eu_suspension.id,
          :taxon_concept_id => @taxon_concept.id
        response.should render_template('new')
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @eu_suspension = create(
        :eu_suspension,
        :taxon_concept_id => @taxon_concept.id
      )
    end
    it "redirects after delete" do
      delete :destroy, :id => @eu_suspension.id,
        :taxon_concept_id => @taxon_concept.id
      response.should redirect_to(
        admin_taxon_concept_eu_suspensions_url(@taxon_concept)
      )
    end
  end
end
