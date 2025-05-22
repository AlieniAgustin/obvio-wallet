class Transaction < ActiveRecord::Base
  belongs_to :source_account, class_name: 'Account'
  belongs_to :target_account, class_name: 'Account'

  validates :transfer_number, :date, :time, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validate :amount_less_than_balance
  validates :description, length: { maximum: 255 }

  def amount_less_than_balance
    if source_account && amount && amount > source_account.balance
      errors.add(:amount, "can't be greater than source account balance")
    end
  end
  
  after_create :transfer_balance

  private

  def transfer_balance
    # Hacer todo en una transacción de DB para evitar inconsistencias
    ActiveRecord::Base.transaction do
      source_account.balance -= amount
      source_account.save!

      target_account.balance += amount
      target_account.save!
    end
  end
end
