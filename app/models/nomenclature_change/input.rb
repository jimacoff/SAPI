# Represents an input of a nomenclature change.
# Inputs are required to be existing taxon concepts.
class NomenclatureChange::Input < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :nomenclature_change_id, :note,
    :taxon_concept_id, :updated_by_id,
    :parent_reassignments_attributes,
    :name_reassignments_attributes,
    :distribution_reassignments_attributes,
    :legislation_reassignments_attributes
  belongs_to :taxon_concept
  has_many :parent_reassignments,
    :class_name => NomenclatureChange::ParentReassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy
  has_many :name_reassignments,
    :class_name => NomenclatureChange::NameReassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy
  has_many :distribution_reassignments,
    :class_name => NomenclatureChange::DistributionReassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy
  has_many :legislation_reassignments,
    :class_name => NomenclatureChange::LegislationReassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy
  validates_presence_of :taxon_concept_id
  accepts_nested_attributes_for :parent_reassignments, :allow_destroy => true
  accepts_nested_attributes_for :name_reassignments, :allow_destroy => true
  accepts_nested_attributes_for :distribution_reassignments, :allow_destroy => true
  accepts_nested_attributes_for :legislation_reassignments, :allow_destroy => true
end
