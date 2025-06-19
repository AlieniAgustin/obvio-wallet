class Account < ActiveRecord::Base
    belongs_to :user  #pertenece a un usuario
    has_one :contact_list, dependent: :destroy # Si una cuenta es eliminada, su lista de contactos tambien es eliminada
    has_many :monthly_summaries, dependent: :destroy
    
    has_many :outgoing_transactions, class_name: "Transaction", foreign_key: "source_account_id"
    has_many :incoming_transactions, class_name: "Transaction", foreign_key: "target_account_id"

    #Vaquitas
    # Vaquitas creadas por la cuenta actual
    has_many :created_vaquitas, class_name: 'Vaquita', foreign_key: 'creator_account_id', dependent: :destroy
    # Vaquitas a las que esta cuenta esta contribuyendo
    has_many :contributions, dependent: :destroy
    has_many :contributed_vaquitas, through: :contributions, source: :vaquita
    
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

    def vaquitaContributionsSum
        Contribution.joins(:vaquita)
                    .where(account_id: id, vaquitas: { status: 'active' })
                    .sum(:amount)    
    end

    private # Seccion privata en la clase Accoun

    def create_contact_list
        ContactList.create!(account: self)
    end

end
