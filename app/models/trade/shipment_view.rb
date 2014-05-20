# == Schema Information
#
# Table name: trade_shipments_view
#
#  id                        :integer
#  year                      :integer
#  appendix                  :string(255)
#  taxon_concept_id          :integer
#  taxon                     :string
#  reported_taxon_concept_id :integer
#  reported_taxon            :string
#  importer_id               :integer
#  importer                  :string(255)
#  exporter_id               :integer
#  exporter                  :string(255)
#  reported_by_exporter      :boolean
#  reporter_type             :text
#  country_of_origin_id      :integer
#  country_of_origin         :string(255)
#  quantity                  :decimal(, )
#  unit_id                   :integer
#  unit                      :string(255)
#  unit_name_en              :string(255)
#  unit_name_es              :string(255)
#  unit_name_fr              :string(255)
#  term_id                   :integer
#  term                      :string(255)
#  term_name_en              :string(255)
#  term_name_es              :string(255)
#  term_name_fr              :string(255)
#  purpose_id                :integer
#  purpose                   :string(255)
#  source_id                 :integer
#  source                    :string(255)
#  import_permit_number      :string(255)
#  export_permit_number      :string(255)
#  origin_permit_number      :string(255)
#  import_permits_ids        :string
#  export_permits_ids        :string
#  origin_permits_ids        :string
#  legacy_shipment_number    :integer
#  created_by                :string(255)
#  updated_by                :string(255)
#

class Trade::ShipmentView < ActiveRecord::Base
  self.table_name = 'trade_shipments_view'
  belongs_to :taxon_concept
end
