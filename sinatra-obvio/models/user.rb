class User < ActiveRecord::Base
    has_secure_password
	has_one :account #tiene una cuenta
        
    validates :email, presence: true, uniqueness: true
	validates :dni, :first_name, :last_name, :address, presence: true #para validar que todos sus campos sean obligatorios

    # after_create :create_account

    # private 

    # def create_account
    #     Account.create!(
    #         user: self,
    #         balance: 0.0,
    #         username: "#{first_name.downcase}.#{last_name.downcase}",
    #         cvu: generate_unique_cvu,
    #         alias: generate_unique_alias
    #     )
    # end

    # # Podés agregar estos métodos como `private` también:
    # def generate_unique_cvu
    #     loop do
    #         cvu = Array.new(22) { rand(0..9) }.join
    #         break cvu unless Account.exists?(cvu: cvu)
    #     end
    # end

    # def generate_unique_alias
    #     loop do
    #         alias_str = "#{first_name.downcase}_#{last_name.downcase}_#{rand(100..999)}"
    #         break alias_str unless Account.exists?(alias: alias_str)
    #     end
    # end

end
