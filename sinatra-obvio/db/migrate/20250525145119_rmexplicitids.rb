class Rmexplicitids < ActiveRecord::Migration[7.2]
  def change
    remove_column :accounts, :id_account, :integer
  end
end
