class ContactListAccount < ActiveRecord::Base
  belongs_to :contact_list
  belongs_to :account

  validates :contact_list_id, presence: true
  validates :account_id, uniqueness: { scope: :contact_list_id, message: "ya está en la lista de contactos" }
  validates :account_id, presence: true
end