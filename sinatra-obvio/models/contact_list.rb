class ContactList < ActiveRecord::Base
    belongs_to :account # contact list owner

    has_many :contact_list_accounts # each contact list can have many entries in contact_lists_accounts (one for each included contact)
    has_many :accounts, through: :contact_list_accounts # shortcut to get all accounts in the contact list without going through the join table (contact_lists_accounts)

    validates :account, presence: true

    def contact_count
        accounts.count
    end
end