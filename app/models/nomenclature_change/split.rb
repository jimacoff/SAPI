class NomenclatureChange::Split < NomenclatureChange
  build_steps(:inputs, :outputs, :notes, :children, :names, :distribution,
    :legislation, :summary)
  attr_accessible :input_attributes, :outputs_attributes
  has_one :input, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy, :autosave => true
  has_many :outputs, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :input, :allow_destroy => true
  accepts_nested_attributes_for :outputs, :allow_destroy => true

  validates :status, inclusion: {
    in: self.status_dict,
    message: "%{value} is not a valid status"
  }
  validate :required_inputs, if: :inputs_or_submitting?
  validate :required_outputs, if: :outputs_or_submitting?
  validate :required_ranks, if: :outputs_or_submitting?
  before_validation :set_outputs_name_status, if: :outputs_or_submitting?
  before_validation :set_outputs_rank_id, if: :outputs_or_submitting?

  def required_inputs
    if input.blank?
      errors.add(:input, "Must have one input")
      return false
    end
  end

  def required_outputs
    if outputs.size < 2
      errors.add(:outputs, "Must have at least two outputs")
      return false
    end
  end

  def required_ranks
    if !(
      outputs.map do |o|
        o.try(:new_rank_id) || o.try(:taxon_concept).try(:rank_id)
      end.uniq - [input.try(:taxon_concept).try(:rank_id)]).empty?
      errors.add(:outputs, "Must be at same rank as input")
      return false
    end
  end

  def set_outputs_name_status
    outputs.each do |output|
      if output.new_scientific_name.present?
        output.new_rank_id = 'A'
      end
    end
  end

  def set_outputs_rank_id
    outputs.each do |output|
      if output.new_scientific_name.present?
        output.new_rank_id = new_output_rank.id
      end
    end
  end

  def outputs_except_inputs
    outputs.reject{ |o| o.taxon_concept == input.try(:taxon_concept) }
  end

  def outputs_intersect_inputs
    outputs.select{ |o| o.taxon_concept == input.try(:taxon_concept) }
  end

  def new_output_rank
    input.taxon_concept.rank
  end

  def new_output_parent
    input.taxon_concept.parent
  end
end
