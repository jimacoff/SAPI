class NomenclatureChange < ActiveRecord::Base
  include Dictionary
  STATUSES = ['new', 'submitted', 'closed']
  build_basic_dictionary(*STATUSES)
  track_who_does_it
  attr_accessible :created_by_id, :event_id, :updated_by_id, :status

  belongs_to :event

  validates :status, presence: true
  validate :cannot_update_when_locked

  def in_progress?
    ![NomenclatureChange::SUBMITTED, NomenclatureChange::CLOSED].
      include?(status)
  end

  def submitting?
    status_changed? && status == NomenclatureChange::SUBMITTED &&
      status_was != NomenclatureChange::CLOSED
  end

  def submit
    if in_progress?
      update_attribute(:status, NomenclatureChange::SUBMITTED)
    end
  end

  def inputs_or_submitting?
    status == NomenclatureChange::Split::INPUTS || submitting?
  end

  def outputs_or_submitting?
    status == NomenclatureChange::Split::OUTPUTS || submitting?
  end

  def outputs_except_inputs
    outputs.reject{ |o| o.taxon_concept == input.try(:taxon_concept) }
  end

  def outputs_intersect_inputs
    outputs.select{ |o| o.taxon_concept == input.try(:taxon_concept) }
  end

  def inputs_intersect_outputs
    inputs.select{ |o| o.taxon_concept == output.try(:taxon_concept) }
  end

  def cannot_update_when_locked
    if status_was == NomenclatureChange::CLOSED ||
      status_was == NomenclatureChange::SUBMITTED &&
      status != NomenclatureChange::CLOSED
      errors[:base] << "Nomenclature change is locked for updates"
      return false
    end
  end

end
