class Account < ActiveRecord::Base
    belongs_to :user  #pertenece a un usuario
end
