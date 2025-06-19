class CreateContributions < ActiveRecord::Migration[7.2]
  def change
    create_table :contributions do |t|
      t.references :account, foreign_key: true
      t.references :vaquita, foreign_key: true
      t.integer :idContribution    # Columna entera para un id personalizado
      t.integer :amount        # Columna para el monto de la contribución

      t.timestamps           # Agrega created_at y updated_at automáticamente
    end
  end
end
