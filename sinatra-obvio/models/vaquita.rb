class Vaquita < ActiveRecord::Base
    self.table_name = 'vaquitas'  # Fuerza el uso de la tabla 'vaquitas'
    
    belongs_to :creator, class_name: 'Account', foreign_key: 'creator_account_id'
    has_many :contributions, dependent: :destroy
    has_many :contributors, through: :contributions, source: :account
    
    validates :name, presence: true
    validates :description, presence: true
    validates :goal, presence: true, numericality: { greater_than: 0 }
    validates :creator_account_id, presence: true
    
    # Status can be: 'active', 'completed', 'withdrawn'
    validates :status, inclusion: { in: ['active', 'completed', 'withdrawn'] }
    
    def current_amount
        contributions.sum(:amount)
    end
    
    def goal_reached?
        current_amount >= goal
    end
    
    def can_be_withdrawn?
        status == 'active' && goal_reached?
    end
    
    def percentage_complete
        return 0 if goal == 0
        [(current_amount.to_f / goal * 100).round(2), 100].min
    end

end
