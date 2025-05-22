class CreateReceipt < ActiveRecord::Migration[7.2]
  def change

    create_table :receipts do |t|
      t.references :transfer, foreign_key: true
      
      t.date :date
      t.time :time
      t.integer :amount
      t.string :description

      t.timestamps
    end

  end
end
