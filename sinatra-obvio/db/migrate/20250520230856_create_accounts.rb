class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts do |t|
      t.integer :idAccount    # Columna entera para un id personalizado (opcional)
      t.float :balance        # Columna para saldo
      t.string :email         # Columna para email
      t.string :username      # Columna para nombre de usuario
      t.string :password      # Columna para contraseña 
      t.timestamps           # Agrega created_at y updated_at automáticamente
    end
  end
end
