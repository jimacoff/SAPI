require 'spec_helper'

describe Checklist do
  include_context :designations
  include_context :ranks
  include_context "Tapiridae"
  include_context "Psittaciformes"
  include_context "Falconiformes"
  include_context "Hirudo medicinalis"

  context "when taxonomic order" do
    before(:all) do
      @checklist = Checklist::Checklist.new({:output_layout => :taxonomic})
      @checklist.generate(0, 100)
      @taxon_concepts = @checklist.taxon_concepts_rel
      #TODO higher taxa are no longer included in taxon_concepts_rel
    end
    it "should include birds after last mammal" do
      @taxon_concepts.index{ |tc| tc.full_name == 'Tapirus terrestris' }.should <
        @taxon_concepts.index{ |tc| tc.full_name == 'Gymnogyps californianus' }
    end
    it "should include Falconiformes (Aves) before Psittaciformes (Aves)" do
      # @taxon_concepts.index{ |tc| tc.full_name == 'Falconiformes' }.should <
        # @taxon_concepts.index{ |tc| tc.full_name == 'Psittaciformes' }
        pending "higher taxa are no longer included in taxon_concepts_rel"
    end
    it "should include Cathartidae within Falconiformes" do
      # @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should >
        # @taxon_concepts.index{ |tc| tc.full_name == 'Falconiformes' }
      # @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should <
        # @taxon_concepts.index{ |tc| tc.full_name == 'Psittaciformes' }
        pending "higher taxa are no longer included in taxon_concepts_rel"
    end
    it "should include Cathartidae (Falconiformes) before Falconidae (Falconiformes)" do
      # @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should <
        # @taxon_concepts.index{ |tc| tc.full_name == 'Falconidae' }
        pending "higher taxa are no longer included in taxon_concepts_rel"
    end
    it "should include Cathartidae (Falconiformes) before Cacatuidae (Psittaciformes)" do
      # @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should <
        # @taxon_concepts.index{ |tc| tc.full_name == 'Cacatuidae' }
        pending "higher taxa are no longer included in taxon_concepts_rel"
    end
    it "should include Hirudo medicinalis at the very end (after all Chordata)" do
      pending "not sure why this fails with travis"
      @taxon_concepts.index{ |tc| tc.full_name == 'Hirudo medicinalis' }.should ==
        @taxon_concepts.length - 1
    end
  end
  context "when alphabetical order" do
    before(:all) do
      @checklist = Checklist::Checklist.new({:output_layout => :alphabetical})
      @taxon_concepts = @checklist.taxon_concepts_rel
    end
    it "should include Falconiformes (Aves) before Psittaciformes (Aves)" do
      # @taxon_concepts.index{ |tc| tc.full_name == 'Falconiformes' }.should <
        # @taxon_concepts.index{ |tc| tc.full_name == 'Psittaciformes' }
        pending "higher taxa are no longer included in taxon_concepts_rel"
    end
    it "should include Cathartidae before Falconiformes" do
      # @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should <
        # @taxon_concepts.index{ |tc| tc.full_name == 'Falconiformes' }
        pending "higher taxa are no longer included in taxon_concepts_rel"
    end
    it "should include Cathartidae (Falconiformes) before Falconidae (Falconiformes)" do
      # @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should <
        # @taxon_concepts.index{ |tc| tc.full_name == 'Falconidae' }
        pending "higher taxa are no longer included in taxon_concepts_rel"
    end
    it "should include Cathartidae (Falconiformes) after Cacatuidae (Psittaciformes)" do
      # @taxon_concepts.index{ |tc| tc.full_name == 'Cathartidae' }.should >
        # @taxon_concepts.index{ |tc| tc.full_name == 'Cacatuidae' }
        pending "higher taxa are no longer included in taxon_concepts_rel"
    end
  end
end