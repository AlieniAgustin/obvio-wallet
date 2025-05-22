class User < ActiveRecord::Base
	has_one :account #tiene una cuenta

	validates :dni, :first_name, :last_name, :address, presence: true #para validar que todos sus campos sean obligatorios
end
