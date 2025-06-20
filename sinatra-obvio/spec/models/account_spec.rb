require_relative '../spec_helper'

RSpec.describe Account do
  let(:user) { User.create!(
    first_name: "Juan",
    last_name: "Perez", 
    email: "juan@example.com",
    dni: "12345678",
    address: "Calle 345",
    password: "password123"
  )}

  describe "Creacion de una cuenta despues de registro" do
    it "crea una cuenta automaticamente despues de que un usuario se registre" do
      expect { user }.to change { Account.count }.by(1)
      expect(user.account).to be_present
    end

    it "configura el balance inicial como 1000000 (10000.00 pesos)" do
      expect(user.account.balance).to eq(1000000)
    end

  end

  describe "validaciones de balance" do
    let(:account) { user.account }

    it "permite balance positivo" do
      account.balance = 50000
      expect(account).to be_valid
    end

    it "permite balance 0" do
      account.balance = 0
      expect(account).to be_valid
    end

    it "does not allow negative balance" do
      account.balance = -1000
      expect(account).not_to be_valid
      expect(account.errors[:balance]).to include("must be greater than or equal to 0")
    end

  end

  describe "validaciones de datos" do
    let(:account) { user.account }

    it "se requiere que el CVU este hecho" do
      account.cvu = nil
      expect(account).not_to be_valid
      expect(account.errors[:cvu]).to include("can't be blank")
    end

    it "se requiere que el CVU sea unico" do
      another_user = User.create!(
        first_name: "Juana",
        last_name: "Hernandez",
        email: "juana@example.com", 
        dni: "87654321",
        address: "Sallorenzo 223",
        password: "password123"
      )
      
      another_user.account.cvu = account.cvu
      expect(another_user.account).not_to be_valid
      expect(another_user.account.errors[:cvu]).to include("has already been taken")
    end

    it "se requiere que el alias este hecho" do
      account.alias = nil
      expect(account).not_to be_valid
      expect(account.errors[:alias]).to include("can't be blank")
    end

    it "se requiere que el alias sea unico" do
      another_user = User.create!(
        first_name: "Juana",
        last_name: "Hernandez",
        email: "juana@example.com", 
        dni: "87654321",
        address: "Sallorenzo 223",
        password: "password123"
      )
      
      another_user.account.alias = account.alias
      expect(another_user.account).not_to be_valid
      expect(another_user.account.errors[:alias]).to include("has already been taken")
    end
  end

  describe "asociaciones" do
    let(:account) { user.account }

    it "le pertenece a un usuario" do
      expect(account.user).to eq(user)
    end

    it "crea una lista de contactos despues de crearse" do
      expect(account.contact_list).to be_present
      expect(account.contact_list).to be_a(ContactList)
    end

    it "se elimina la lista de contactos cuando la cuenta es eliminada" do
      contact_list = account.contact_list
      expect { account.destroy }.to change { ContactList.count }.by(-1)
    end

    it "tiene muchas transacciones enviadas" do
      expect(account).to respond_to(:outgoing_transactions)
    end

    it "tiene muchas transacciones recibidas" do
      expect(account).to respond_to(:incoming_transactions)
    end

    it "tiene muchas vaquitas creadas" do
      expect(account).to respond_to(:created_vaquitas)
    end

    it "tiene muchas contribuciones" do
      expect(account).to respond_to(:contributions)
    end
  end

  describe "callbacks" do
    it "se crea una lista de contactos despues de la creacion de la cuenta" do
      new_user = User.new(
        first_name: "Santiago",
        last_name: "Llorente",
        email: "santiago@example.com",
        dni: "11111111",
        address: "San Martin 342", 
        password: "password123"
      )
      
      expect { new_user.save! }.to change { ContactList.count }.by(1)
      expect(new_user.account.contact_list).to be_present
    end
  end
end
