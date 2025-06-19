class FixContributionsVaquitaForeignKey < ActiveRecord::Migration[7.2]
  def change
    # Remover el foreign key incorrecto (vaquita en singular)
    remove_foreign_key :contributions, :vaquita if foreign_key_exists?(:contributions, :vaquita)
    
    # Agregar el foreign key correcto (vaquita en plural)
    add_foreign_key :contributions, :vaquitas, column: :vaquita_id
  end
end