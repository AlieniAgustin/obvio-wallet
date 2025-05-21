class Account < ActiveRecord::Base
    belongs_to :user  #pertenece a un usuario
    has_one :monthly_summaries, :contact_list, dependent: :destroy # If an account is deleted, its contact list is also deleted
    
    validates :id_account, presence: true, uniqueness: true
    validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :email, presence: true, uniqueness: true 
    validates :username, presence: true, uniqueness: true 
    validates :password, presence: true # TODO: add password hashing
    validates :cvu, presence: true, uniqueness: true
    validates :alias, presence: true, uniqueness: true

    after_create :create_contact_list

    private # private section within class Account

    def create_contact_list
        ContactList.create!(account: self)
    end
end
