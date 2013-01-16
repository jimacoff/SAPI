# == Schema Information
#
# Table name: taxon_relationships
#
#  id                         :integer          not null, primary key
#  taxon_concept_id           :integer          not null
#  other_taxon_concept_id     :integer          not null
#  taxon_relationship_type_id :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class TaxonRelationship < ActiveRecord::Base
  attr_accessible :taxon_concept_id, :other_taxon_concept_id, :taxon_relationship_type_id
  belongs_to :taxon_relationship_type
  belongs_to :taxon_concept
  belongs_to :other_taxon_concept, :class_name => 'TaxonConcept',
    :foreign_key => :other_taxon_concept_id

  validates :taxon_concept_id, :uniqueness => { :scope => [:taxon_relationship_type_id, :other_taxon_concept_id], :message => 'This particular relationship already exists' }

  delegate :is_bidirectional?, :to => :taxon_relationship_type
  before_destroy :destroy_opposite, :if => Proc.new { self.is_bidirectional? && self.has_opposite? }
  after_create :create_opposite, :if => Proc.new { self.is_bidirectional? && !self.has_opposite? }

  def opposite
    TaxonRelationship.where(:taxon_concept_id => self.other_taxon_concept_id,
      :other_taxon_concept_id => self.taxon_concept_id,
      :taxon_relationship_type_id => self.taxon_relationship_type_id).first
  end

  def has_opposite?
    opposite.present?
  end

  private
  def create_opposite
    TaxonRelationship.create(
      :taxon_concept_id => self.other_taxon_concept_id,
      :other_taxon_concept_id => self.taxon_concept_id,
      :taxon_relationship_type_id => self.taxon_relationship_type_id)
  end

  def destroy_opposite
    TaxonRelationship.where(
        :taxon_concept_id => self.other_taxon_concept_id,
        :other_taxon_concept_id => self.taxon_concept_id,
        :taxon_relationship_type_id => self.taxon_relationship_type_id).
      delete_all
  end
end
