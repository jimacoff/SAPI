# Represents an output of a nomenclature change.
# Outputs may be new taxon concepts, crated as a result of the nomenclature
# change.
class NomenclatureChange::Output < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :new_author_year, :new_full_name, :new_name_status, :new_parent_id, :new_rank_id, :new_taxon_concept_id, :nomenclature_change_id, :note, :taxon_concept_id, :updated_by_id
  belongs_to :taxon_concept
  has_many :reassignment_targets, :class_name => NomenclatureChange::ReassignmentTarget,
    :foreign_key => :nomenclature_change_output_id, :dependent => :destroy
  belongs_to :new_parent, :class_name => TaxonConcept, :foreign_key => :new_parent_id
  belongs_to :new_rank, :class_name => Rank, :foreign_key => :new_rank_id
  validates_presence_of :new_full_name, :if => Proc.new { |c| c.taxon_concept_id.blank? }
  validates_presence_of :new_author_year, :if => Proc.new { |c| c.taxon_concept_id.blank? }
  validates_presence_of :new_name_status, :if => Proc.new { |c| c.taxon_concept_id.blank? }
  validates_presence_of :new_parent_id, :if => Proc.new { |c| c.taxon_concept_id.blank? }
  validates_presence_of :new_rank_id, :if => Proc.new { |c| c.taxon_concept_id.blank? }

  def new_full_name
    rank = new_rank || nomenclature_change.input.taxon_concept.rank
    parent = new_parent || nomenclature_change.input.taxon_concept.parent
    name = read_attribute(:new_full_name)
    if [Rank::SPECIES, Rank::SUBSPECIES].include?(rank.name)
      parent.full_name + ' ' + name
    elsif rank.name == Rank::VARIETY
      parent.full_name + ' var. ' + name
    else
      name
    end
  end

  def display_full_name; new_full_name || taxon_concept.try(:full_name); end

  def transformations_summary
    res = []
    rank_name = new_rank.try(:name) || taxon_concept.try(:rank).try(:name)
    full_name = display_full_name
    name_status = new_name_status || taxon_concept.try(:name_status)
    if taxon_concept.blank?
      res << "New #{rank_name} #{full_name} (#{name_status}) will be created"
    elsif taxon_concept.full_name != new_full_name
      res << "New #{rank_name} #{full_name} (#{name_status}) will be created, based on #{taxon_concept.full_name}"
    else
      changes = []
      if new_rank
        changes << "rank changed from #{taxon_concept.rank.name} to #{new_rank.name}"
      end
      if new_parent
        changes << "parent changed from #{taxon_concept.parent.full_name} to #{new_parent.full_name}"
      end
      if new_name_status
        changes << "name status changed from #{taxon_concept.name_status} to #{new_name_status}"
      end
      if new_author_year
        changes << "author year changed from #{taxon_concept.author_year} to #{new_author_year}"
      end
      changes.compact!
      unless changes.empty?
        res << "The following changes will be applied to #{taxon_concept.full_name}:"
        res << changes
      end
    end
    res
  end

end
