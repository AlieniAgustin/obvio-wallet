class CreateContactLists < ActiveRecord::Migration[7.2]
  def change
    create_table :contact_lists do |t|
      t.references :account, null: false, foreign_key: true # contact list owner
      t.timestamps
    end
  end
end
