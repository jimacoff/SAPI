# == Schema Information
#
# Table name: documents
#
#  id                           :integer          not null, primary key
#  title                        :text             not null
#  filename                     :text             not null
#  date                         :date             not null
#  type                         :string(255)      not null
#  is_public                    :boolean          default(FALSE), not null
#  event_id                     :integer
#  language_id                  :integer
#  elib_legacy_id               :integer
#  created_by_id                :integer
#  updated_by_id                :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  number                       :string(255)
#  sort_index                   :integer
#  primary_language_document_id :integer
#  elib_legacy_file_name        :text
#  original_id                  :integer
#  discussion_id                :integer
#  discussion_sort_index        :integer
#

class Document::ReviewOfSignificantTrade < Document
  def self.display_name; 'Review of Significant Trade'; end

  attr_accessible :review_details_attributes

  has_one :review_details,
    :class_name => 'Document::ReviewDetails',
    :foreign_key => 'document_id'
  accepts_nested_attributes_for :review_details, :allow_destroy => true
end
