class ElimiarTablaporeror < ActiveRecord::Migration[7.2]
  def change
    drop_table :vouchers
  end
end
