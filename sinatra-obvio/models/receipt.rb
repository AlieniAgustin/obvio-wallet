class Receipt < ActiveRecord::Base
  belongs_to :transfer

  validates :date, presence: true
  validates :time, presence: true
  validates :amount, presence: true
end
