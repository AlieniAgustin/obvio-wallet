class ContactListAccount < ActiveRecord::Base
  belongs_to :contact_list
  belongs_to :account

  validates :contact_list_id, presence: true
  validates :account_id, presence: true
end