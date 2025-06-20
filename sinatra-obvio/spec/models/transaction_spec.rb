require_relative '../spec_helper'

RSpec.describe Transaction do
  let(:user1) { User.create!(
    first_name: "Juan",
    last_name: "Perez", 
    email: "juan@example.com",
    dni: "12345678",
    address: "Calle 345",
    password: "password123"
  ) }
  let(:user2) { User.create!(
        first_name: "Juana",
        last_name: "Hernandez",
        email: "juana@example.com", 
        dni: "87654321",
        address: "Sallorenzo 223",
        password: "password123"
      ) }
  let(:source_account) { user1.account }
  let(:target_account) { user2.account }

  before do
    # Inicializo los balances
    source_account.update!(balance: 1000)
    target_account.update!(balance: 500)
    
    # Agrego el target account a la lista de contactos del source account
    contact_list_account = ContactListAccount.create!(
      contact_list: source_account.contact_list,
      account: target_account
    )
  end

  describe "validaciones" do
    it "la transaccion no se puede realizar si el source account no tiene suficiente dinero" do
      transaction = Transaction.new(
        source_account: source_account,
        target_account: target_account,
        amount: 1500, # Mas que el balance del source account
        transaction_number: "123",
        date: Date.current,
        time: Time.current,
        description: "Test transaccion"
      )

      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include("can't be greater than source account balance")
    end
  end

  describe "balance se actualiza" do
    it "se actualiza el balance de cada cuenta correctamente despues de que la transaccion se realizo" do
      initial_source_balance = source_account.balance
      initial_target_balance = target_account.balance
      transaction_amount = 200

      transaction = Transaction.create!(
        source_account: source_account,
        target_account: target_account,
        amount: transaction_amount,
        transaction_number: "TXN125",
        date: Date.current,
        time: Time.current,
        description: "Test transaction"
      )

      source_account.reload
      target_account.reload

      expect(source_account.balance).to eq(initial_source_balance - transaction_amount)
      expect(target_account.balance).to eq(initial_target_balance + transaction_amount)
    end
  end

end
