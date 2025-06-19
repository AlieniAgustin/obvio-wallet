class Contribution < ActiveRecord::Base
    belongs_to :account
    belongs_to :vaquita
    
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :account_id, presence: true
    validates :vaquita_id, presence: true
    validates :account_id, uniqueness: {
        scope: :vaquita_id,
        message: "ya contribuyó a esta vaquita"
    }

    after_create :update_vaquita_amount
    after_update :update_vaquita_amount
    after_destroy :update_vaquita_amount
    
    def can_be_withdrawn?
        vaquita.status == 'active'
    end

    def update_vaquita_amount
        vaquita.update_current_amount!
    end
end
