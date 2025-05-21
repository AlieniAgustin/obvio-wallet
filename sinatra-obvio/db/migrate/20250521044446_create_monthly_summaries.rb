class CreateMonthlySummaries < ActiveRecord::Migration[7.2]
  def change
    create_table :monthly_summaries do |t|
      t.references :account, foreign_key: true
      t.decimal :initial_balance, precision: 15, scale: 2, null: false
      t.decimal :final_balance, precision: 15, scale: 2, null: false
      t.text :note
      t.string :balance_status
      t.integer :transaction_count
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
