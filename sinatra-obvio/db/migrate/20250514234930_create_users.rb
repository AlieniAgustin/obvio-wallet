class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :first_name      #Columna para el nombre
      t.string :last_name       #Columna para el apellido
      t.string :dni             #Columna para el dni
      t.string :address         #Columna para la direccion
      t.timestamps
    end
  end
end
