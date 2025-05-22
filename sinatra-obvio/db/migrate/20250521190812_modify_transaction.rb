class ModifyTransaction < ActiveRecord::Migration[7.2]
  def change
    rename_column :transactions, :num_transaction, :transfer_number
    rename_column :transactions, :day, :date
    rename_column :transactions, :hour, :time
    rename_column :transactions, :money, :amount
    rename_column :transactions, :desc, :description
    rename_column :transactions, :motive, :reason
  end
end

