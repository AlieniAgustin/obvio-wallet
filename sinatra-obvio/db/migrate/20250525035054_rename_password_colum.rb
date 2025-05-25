class RenamePasswordColum < ActiveRecord::Migration[7.2]
  def change
    remove_column :accounts, :password, :string
    remove_column :accounts, :username, :string
    remove_column :accounts, :email, :string

    add_column :users, :email, :string
    add_column :users, :password_digest, :string
  end
end
