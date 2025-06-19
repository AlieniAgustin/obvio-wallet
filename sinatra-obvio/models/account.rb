class Account < ActiveRecord::Base
    belongs_to :user  #pertenece a un usuario
    has_one :contact_list, dependent: :destroy # If an account is deleted, its contact list is also deleted
    has_many :monthly_summaries, dependent: :destroy
    
    has_many :outgoing_transactions, class_name: "Transaction", foreign_key: "source_account_id"
    has_many :incoming_transactions, class_name: "Transaction", foreign_key: "target_account_id"

    #Vaquitas
    has_many :vaquitas, dependent: :destroy
    has_many :contributions, dependent: :destroy
    
    validates :cvu, presence: true, uniqueness: true
    validates :alias, presence: true, uniqueness: true

    after_create :create_contact_list

    # Permite hacer directamente: account.transactions
    def transactions
        Transaction.where("source_account_id = ? OR target_account_id = ?", id, id)
    end
    
    def recent_transactions(limit = 10)
        transactions.order(date: :desc, time: :desc).limit(limit)
    end

    private # private section within class Account

    def create_contact_list
        ContactList.create!(account: self)
    end

end
