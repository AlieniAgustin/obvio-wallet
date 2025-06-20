class RemoveUnusedTables < ActiveRecord::Migration[7.2]
  def up
    # Borro las tablas que al final no fueron necesarias
    drop_table :receipts if table_exists?(:receipts)
    drop_table :monthly_summaries if table_exists?(:monthly_summaries)
  end

  def down
    # Recrear receipts si hace falta hacer rollback
    create_table :receipts do |t|
      t.integer :transfer_id
      t.date :date
      t.time :time
      t.integer :amount
      t.string :description
      t.timestamps
    end
    add_index :receipts, :transfer_id

    # Recrear monthly_summaries si hace falta hacer rollback
    create_table :monthly_summaries do |t|
      t.integer :initial_balance, null: false
      t.integer :final_balance, null: false
      t.text :note
      t.string :balance_status
      t.integer :transaction_count
      t.integer :account_id
      t.timestamps
    end
    add_index :monthly_summaries, :account_id
    add_foreign_key :monthly_summaries, :accounts
  end
end