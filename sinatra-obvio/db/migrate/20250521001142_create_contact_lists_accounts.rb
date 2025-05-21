# Many-to-many relationship between contact lists and accounts
class CreateContactListsAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :contact_lists_accounts do |t|
      t.references :contact_list, null: false, foreign_key: true # contact list
      t.references :account, null: false, foreign_key: true # contact list member
      t.timestamps
    end

    # Unique index to prevent duplicate entries (same contact can't be in the same list more than once)
    add_index :contact_lists_accounts, [:contact_list_id, :account_id], unique: true
  end
end
