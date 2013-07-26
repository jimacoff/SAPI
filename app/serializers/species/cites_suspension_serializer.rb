class Species::CitesSuspensionSerializer < ActiveModel::Serializer
  attributes :notes, {:start_date_formatted => :start_date},
    {:end_date_formatted => :end_date}, :is_current, :subspecies_info
  has_one :geo_entity, :serializer => Species::GeoEntitySerializer
  has_one :start_notification, :serializer => Species::EventSerializer
  has_one :end_notification, :serializer => Species::EventSerializer
end

