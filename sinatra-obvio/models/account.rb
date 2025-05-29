class Account < ActiveRecord::Base
    belongs_to :user  #pertenece a un usuario
    has_one :contact_list, dependent: :destroy # If an account is deleted, its contact list is also deleted
    has_many :monthly_summaries, dependent: :destroy

    validates :cvu, presence: true, uniqueness: true
    validates :alias, presence: true, uniqueness: true

    after_create :create_contact_list

    private # private section within class Account

    def create_contact_list
        ContactList.create!(account: self)
    end
end
