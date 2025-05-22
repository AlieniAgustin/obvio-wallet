class AddUserIdToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_reference :accounts, :user, foreign_key: true
  end
end
