class CreateMonthlySummaries < ActiveRecord::Migration[7.2]
  def change
    create_table :monthly_summaries do |t|
      
      t.integer :initial_balance, null: false
      t.integer :final_balance, null: false
      t.text :note
      t.string :balance_status
      t.integer :transaction_count
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
