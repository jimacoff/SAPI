# == Schema Information
#
# Table name: eu_decisions
#
#  id                         :integer          not null, primary key
#  is_current                 :boolean          default(TRUE)
#  notes                      :text
#  internal_notes             :text
#  taxon_concept_id           :integer
#  geo_entity_id              :integer
#  start_date                 :datetime
#  start_event_id             :integer
#  end_date                   :datetime
#  end_event_id               :integer
#  type                       :string(255)
#  conditions_apply           :boolean
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  eu_decision_type_id        :integer
#  term_id                    :integer
#  source_id                  :integer
#  created_by_id              :integer
#  updated_by_id              :integer
#  nomenclature_note_en       :text
#  nomenclature_note_es       :text
#  nomenclature_note_fr       :text
#  internal_nomenclature_note :text
#

class EuOpinion < EuDecision
  validates :start_date, presence: true
end
