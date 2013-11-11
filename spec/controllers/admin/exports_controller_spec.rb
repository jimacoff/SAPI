require 'spec_helper'

describe Admin::ExportsController do
  after(:each) do
    DownloadsCache.clear_taxon_concepts_names
  end
  describe "GET index" do
    it "renders the index template" do
      get :index
      response.should render_template("index")
      response.should render_template("layouts/admin")
    end
  end
  describe "GET download" do
    context "all" do
      it "returns taxon concepts names file" do
        create(:taxon_concept)
        Species::TaxonConceptsNamesExport.any_instance.stub(:public_file_name).and_return('taxon_concepts_names.csv')
        get :download
        response.content_type.should eq("text/csv")
        response.headers["Content-Disposition"].should eq("attachment; filename=\"taxon_concepts_names.csv\"")
      end
      it "redirects when no results" do
        get :download
        response.should redirect_to(admin_exports_path)
      end
    end
    context "CITES_EU" do
      it "returns CITES_EU taxon concepts names file" do
        create_cites_eu_species
        Species::TaxonConceptsNamesExport.any_instance.stub(:public_file_name).and_return('taxon_concepts_names.csv')
        get :download, :filters => {:taxonomy => 'CITES_EU'}
        response.content_type.should eq("text/csv")
        response.headers["Content-Disposition"].should eq("attachment; filename=\"taxon_concepts_names.csv\"")
      end
      it "redirects when no results" do
        get :download, :filters => {:taxonomy => 'CITES_EU'}
        response.should redirect_to(admin_exports_path)
      end
    end
    context "CMS" do
      it "returns CMS taxon concepts names file" do
        create_cms_species
        Species::TaxonConceptsNamesExport.any_instance.stub(:public_file_name).and_return('taxon_concepts_names.csv')
        get :download, :filters => {:taxonomy => 'CMS'}
        response.content_type.should eq("text/csv")
        response.headers["Content-Disposition"].should eq("attachment; filename=\"taxon_concepts_names.csv\"")
      end
      it "redirects when no results" do
        get :download, :filters => {:taxonomy => 'CMS'}
        response.should redirect_to(admin_exports_path)
      end
    end
  end
end