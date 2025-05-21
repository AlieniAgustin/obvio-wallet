class MonthlySummary < ActiveRecord::Base
	belongs_to :account

	validates :month, presence: true
	validates :year, presence: true
	validates :account_id, presence: true
	validates :initial_balance, presence: true
	validates :final_balance, presence: true
	validates :transaction_count, presence: true
	validates :balance_status, presence: true


end
