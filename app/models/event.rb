class Event < ActiveRecord::Base
  attr_accessible :name, :designation_id, :description, :url, :effective_at,
    :listing_changes_event_id
  attr_accessor :listing_changes_event_id
  belongs_to :designation
  has_many :listing_changes
  validates :name, :presence => true, :uniqueness => true

  def effective_at_formatted
    effective_at && effective_at.strftime("%d/%m/%y")
  end

end
