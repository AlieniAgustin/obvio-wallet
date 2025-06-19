class CreateVaquitas < ActiveRecord::Migration[7.2]
  def change
    create_table :vaquitas do |t|
      t.integer :idVaquita    # Columna entera para un id personalizado (opcional)
      t.integer :balance        # Columna para saldo
      t.timestamps           # Agrega created_at y updated_at automáticamente
    end
  end
end
