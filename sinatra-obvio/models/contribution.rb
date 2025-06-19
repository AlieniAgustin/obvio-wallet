class Contribution < ActiveRecord::Base
    belongs_to :account
    belongs_to :vaquita
    
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :account_id, presence: true
    validates :vaquita_id, presence: true
    
    def can_be_withdrawn?
        vaquita.status == 'active'
    end

end
