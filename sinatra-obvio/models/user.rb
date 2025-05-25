class User < ActiveRecord::Base
        has_secure_password
	has_one :account #tiene una cuenta
        
        validates :email, presence: true, uniqueness: true
	validates :dni, :first_name, :last_name, :address, presence: true #para validar que todos sus campos sean obligatorios
end
