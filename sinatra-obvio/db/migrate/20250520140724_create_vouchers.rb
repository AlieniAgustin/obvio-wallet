class CreateVouchers < ActiveRecord::Migration[7.2]
  def change
    create_table :vouchers do |t|
      t.string :code, null: false
      t.references :wallet, null: false, foreign_key: true
      t.timestamps
    end

    add_index :vouchers, :code, unique: true
    add_index :vouchers, :wallet_id, unique: true  # Solo si querés que haya 1 voucher por wallet
  end
end
