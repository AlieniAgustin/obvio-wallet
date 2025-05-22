class ModifyTransaction2 < ActiveRecord::Migration[7.2]
  def change
    rename_column :transactions, :transfer_number, :transaction_number
  end
end
