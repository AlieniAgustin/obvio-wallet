class CreateVouchers < ActiveRecord::Migration[7.2]
  def change

    create_table :vouchers do |t|
      t.date :dia
      t.time :hora
      t.decimal :importe, precision: 10, scale: 2
      t.string :description

      t.references :transfer, null: false, foreign_key: true, unique: true
      t.timestamps
    end


  end
end
