# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#  run_order         :integer          not null
#  column_names      :string(255)
#  is_primary        :boolean          default(TRUE), not null
#  scope             :hstore
#

require 'spec_helper'

describe Trade::PovInclusionValidationRule, :drops_tables => true do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:canada){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Canada',
      :iso_code2 => 'CA'
    )
  }
  let(:argentina){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Argentina',
      :iso_code2 => 'AR'
    )
  }
  before(:each) do
    genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pecari')
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Tajacu'),
      :parent => genus
    )
    create(
      :distribution,
      :taxon_concept => @species,
      :geo_entity => argentina
    )
  end
  describe :validation_errors do
    context "when W source and country of origin blank and exporter doesn't match distribution (E)" do
      before(:each) do
        @aru = build(:annual_report_upload, :point_of_view => 'E', :trading_country_id => canada.id)
        @aru.save(:validate => false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
        sandbox_klass.create(
          :species_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => nil
        )
        sandbox_klass.create(
          :species_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => argentina.iso_code2
        )
      end
      subject{
        create(
          :pov_inclusion_validation_rule,
          :scope => {:source_code => 'W', :country_of_origin_blank => true},
          :column_names => ['species_name', 'exporter'],
          :valid_values_view => 'valid_species_name_exporter_view'
        )
      }
      specify{
        subject.validation_errors(@aru).size.should == 1
      }
      specify{
        ve = subject.validation_errors(@aru).first
        ve.error_selector.should == {'species_name' => 'Pecari tajacu', 'country_of_origin' => nil, 'source_code' => 'W'}
      }
    end
    context "when W source and country of origin blank and exporter doesn't match distribution (I)" do
      before(:each) do
        @aru = build(:annual_report_upload, :point_of_view => 'I', :trading_country_id => argentina.id)
        @aru.save(:validate => false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
        sandbox_klass.create(
          :species_name => 'Pecari tajacu', :source_code => 'W',
          :trading_partner => canada.iso_code2, :country_of_origin => nil
        )
        sandbox_klass.create(
          :species_name => 'Pecari tajacu', :source_code => 'W',
          :trading_partner => canada.iso_code2,
          :country_of_origin => argentina.iso_code2
        )
      end
      subject{
        create(
          :pov_inclusion_validation_rule,
          :scope => {:source_code => 'W', :country_of_origin_blank => true},
          :column_names => ['species_name', 'exporter'],
          :valid_values_view => 'valid_species_name_exporter_view'
        )
      }
      specify{
        subject.validation_errors(@aru).size.should == 1
      }
      specify{
        ve = subject.validation_errors(@aru).first
        ve.error_selector.should == {
          'species_name' => 'Pecari tajacu', 'country_of_origin' => nil,
          'source_code' => 'W', 'trading_partner' => canada.iso_code2}
      }
    end
    context "when invalid scope specified" do
      before(:each) do
        @aru = build(:annual_report_upload, :point_of_view => 'E', :trading_country_id => canada.id)
        @aru.save(:validate => false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
        sandbox_klass.create(
          :species_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => argentina.iso_code2
        )
      end
      subject{
        create(
          :pov_inclusion_validation_rule,
          :scope => {:source_code => 'W', :country_of_originnn_blank => true},
          :column_names => ['species_name', 'exporter'],
          :valid_values_view => 'valid_species_name_exporter_view'
        )
      }
      specify{
        expect{ subject.validation_errors(@aru) }.to_not raise_error(ActiveRecord::StatementInvalid)
      }
    end
  end
end