class ImproveVaquitas < ActiveRecord::Migration[7.2]
  def change
    # Primero, chequeo si puedo, y luego modifico la tabla vaquitas
    unless column_exists?(:vaquitas, :creator_account_id)
      add_column :vaquitas, :creator_account_id, :integer
    end
    
    unless column_exists?(:vaquitas, :status)
      add_column :vaquitas, :status, :string, default: 'active'
    end
    
    unless column_exists?(:vaquitas, :goal)
      add_column :vaquitas, :goal, :integer
    end
    
    unless column_exists?(:vaquitas, :name)
      add_column :vaquitas, :name, :string
    end
    
    unless column_exists?(:vaquitas, :description)
      add_column :vaquitas, :description, :string
    end
    
    # Renombro columnas si es que existen
    if column_exists?(:vaquitas, :balance)
      rename_column :vaquitas, :balance, :current_amount
    end
    
    if column_exists?(:vaquitas, :idVaquitas)
      rename_column :vaquitas, :idVaquitas, :vaquita_id
    end
    
    # Agrego claves foraneas e indexes
    unless foreign_key_exists?(:vaquitas, :accounts, column: :creator_account_id)
      add_foreign_key :vaquitas, :accounts, column: :creator_account_id
    end
    
    add_index :vaquitas, :creator_account_id unless index_exists?(:vaquitas, :creator_account_id)
    add_index :vaquitas, :status unless index_exists?(:vaquitas, :status)
    
    # Me aseguro que contributions tiene la clave foranea vaquita_id
    unless column_exists?(:contributions, :vaquita_id)
      add_column :contributions, :vaquita_id, :integer, null: false
      add_foreign_key :contributions, :vaquitas, column: :vaquita_id
    end
    
    # Arreglo el constraint unique a la tabla contributions
    unless index_exists?(:contributions, [:account_id, :vaquita_id])
      add_index :contributions, [:account_id, :vaquita_id], unique: true
    end
  end
  
  def down
    # Si algo falla, saco las modificaciones
    remove_foreign_key :vaquitas, :accounts if foreign_key_exists?(:vaquitas, :accounts)
    remove_foreign_key :contributions, :vaquitas if foreign_key_exists?(:contributions, :vaquitas)
    
    remove_index :vaquitas, :creator_account_id if index_exists?(:vaquitas, :creator_account_id)
    remove_index :vaquitas, :status if index_exists?(:vaquitas, :status)
    remove_index :contributions, [:account_id, :vaquita_id] if index_exists?(:contributions, [:account_id, :vaquita_id])
    
    remove_column :vaquitas, :creator_account_id if column_exists?(:vaquitas, :creator_account_id)
    remove_column :vaquitas, :status if column_exists?(:vaquitas, :status)
    remove_column :vaquitas, :goal if column_exists?(:vaquitas, :goal)
    remove_column :vaquitas, :name_vaquita if column_exists?(:vaquitas, :name_vaquita)
    remove_column :vaquitas, :description if column_exists?(:vaquitas, :description)
    remove_column :contributions, :vaquita_id if column_exists?(:contributions, :vaquita_id)
    
    rename_column :vaquitas, :current_amount, :balance if column_exists?(:vaquitas, :current_amount)
    rename_column :vaquitas, :vaquita_id, :idVaquitas if column_exists?(:vaquitas, :vaquita_id)
  end
end