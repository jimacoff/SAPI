class Checklist::ChecklistSerializer < ActiveModel::Serializer
  cached
  attributes :result_cnt, :total_cnt #TODO move this to a meta object for consistency with Species+
  has_many :animalia, :serializer => Checklist::TaxonConceptSerializer
  has_many :plantae, :serializer => Checklist::TaxonConceptSerializer

  def result_cnt
    object.taxon_concepts.size
  end
end
