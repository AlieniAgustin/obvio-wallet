class ChangeDateTimeTypeInTransactions < ActiveRecord::Migration[7.2]
  def change
    change_column :transactions, :date, :date
    change_column :transactions, :time, :time
  end
end
