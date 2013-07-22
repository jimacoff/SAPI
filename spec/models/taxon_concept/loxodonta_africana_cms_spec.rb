require 'spec_helper'

describe TaxonConcept do
  context "Loxodonta africana CMS" do
    include_context "Loxodonta africana CMS"
    context "TAXONOMY" do
      describe :full_name do
        context "for species Loxodonta africana" do
          specify{ @species.full_name.should == 'Loxodonta africana' }
        end
        context "for genus Loxodonta" do
          specify{ @genus.full_name.should == 'Loxodonta' }
        end
      end
      describe :rank do
        context "for species Loxodonta africana" do
          specify{ @species.rank_name.should == 'SPECIES' }
        end
      end
      describe :ancestors do
        context "family" do
          specify{ @species.family_name == 'Elephantidae' }
        end
        context "order" do
          specify{ @species.order_name == 'Proboscidea' }
        end
        context "class" do
          specify{ @species.class_name == 'Mammalia' }
        end
      end
    end

    context "LISTING" do
      describe :cms_listing do
        context "for species Loxodonta africana" do
          specify{ @species.cms_listing.should == 'II' }
        end
      end

      describe :cms_listed do
        context "for species Loxodonta africana" do
          specify{ @species.cms_listed.should be_true }
        end
      end
    end
  end
end