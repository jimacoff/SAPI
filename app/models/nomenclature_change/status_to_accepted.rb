# == Schema Information
#
# Table name: nomenclature_changes
#
#  id            :integer          not null, primary key
#  event_id      :integer
#  type          :string(255)      not null
#  status        :string(255)      not null
#  created_by_id :integer          not null
#  updated_by_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# A status change to A needs to have one output.
class NomenclatureChange::StatusToAccepted < NomenclatureChange
  include NomenclatureChange::StatusChangeHelpers
  build_steps(
    :primary_output, :receive, :notes, :legislation, :summary
  )
  validates :status, inclusion: {
    in: self.status_dict,
    message: "%{value} is not a valid status"
  }
  before_validation :ensure_new_name_status, if: :primary_output?

  def ensure_new_name_status
    primary_output && primary_output.new_name_status = 'A'
  end

  def needs_to_receive_associations?
    ['S', 'T'].include?(primary_output.try(:name_status))
  end

  def needs_to_relay_associations?
    false
  end

  def build_auto_reassignments
    # Reassignments will only be required when there is an input
    # from which to reassign
    if input
      builder = NomenclatureChange::StatusToAccepted::Constructor.new(self)
      builder.build_parent_reassignments
      builder.build_name_reassignments
      builder.build_distribution_reassignments
      builder.build_legislation_reassignments
      builder.build_common_names_reassignments
      builder.build_references_reassignments
      builder.build_trade_reassignments
    end
    true
  end

end
