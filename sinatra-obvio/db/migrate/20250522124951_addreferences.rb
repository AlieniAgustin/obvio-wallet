class Addreferences < ActiveRecord::Migration[7.2]
  def change

    add_reference :transactions, :source_account, null: false, foreign_key: { to_table: :accounts }
    add_reference :transactions, :target_account, null: false, foreign_key: { to_table: :accounts }
  end
end
