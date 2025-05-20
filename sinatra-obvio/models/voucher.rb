class Voucher < ActiveRecord::Base
  belongs_to :transfer

  validates :dia, presence: true
  validates :hora, presence: true  
  validates :importe, presence: true
end  
