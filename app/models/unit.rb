# == Schema Information
#
# Table name: trade_codes
#
#  id         :integer          not null, primary key
#  code       :string(255)      not null
#  name_en    :string(255)      not null
#  type       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name_es    :string(255)
#  name_fr    :string(255)
#

class Unit < TradeCode
  validates :code, :length => {:is => 3}

  has_many :term_trade_codes_pairs, :as => :trade_code
  has_many :shipments, :class_name => 'Trade::Shipment'

  def can_be_deleted?
    Quota.where(:unit_id => self.id).length == 0 &&
    shipments.limit(1).count == 0
  end
end
