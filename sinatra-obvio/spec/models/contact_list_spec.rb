require_relative '../spec_helper'

RSpec.describe ContactList do
  let(:owner) do
    User.create!(
      email: "owner@example.com",
      password: "password",
      password_confirmation: "password",
      dni: "12345678",
      first_name: "Owner",
      last_name: "User",
      address: "Fake St 123"
    ).account
  end

  let(:contact1) do
    User.create!(
      email: "contact1@example.com",
      password: "password",
      password_confirmation: "password",
      dni: "87654321",
      first_name: "Contact",
      last_name: "One",
      address: "Fake St 456"
    ).account
  end

  let(:contact2) do
    User.create!(
      email: "contact2@example.com",
      password: "password",
      password_confirmation: "password",
      dni: "11223344",
      first_name: "Contact",
      last_name: "Two",
      address: "Fake St 789"
    ).account
  end

  describe "Creación automática" do
    it "se crea automáticamente una lista de contactos al crear una cuenta" do
      expect(owner.contact_list).to be_present
      expect(owner.contact_list.account).to eq(owner)
    end
  end

  describe "Validaciones" do
    it "no es válida sin una cuenta asociada" do
      contact_list = ContactList.new
      expect(contact_list).not_to be_valid
    end
  end

  describe "Contar contactos" do
    it "devuelve 0 si no hay contactos" do
      expect(owner.contact_list.contact_count).to eq(0)
    end

    it "devuelve el número correcto de contactos" do
      cl = owner.contact_list
      cl.accounts << contact1
      cl.accounts << contact2
      expect(cl.contact_count).to eq(2)
    end
  end

  describe "Agregar y quitar contactos" do
    it "puede agregar contactos a la lista" do
      cl = owner.contact_list
      expect {
        cl.accounts << contact1
      }.to change { cl.accounts.count }.by(1)
    end

    it "puede quitar contactos de la lista" do
      cl = owner.contact_list
      cl.accounts << contact1
      expect {
        cl.accounts.delete(contact1)
      }.to change { cl.accounts.count }.by(-1)
    end

   it "no agrega el mismo contacto dos veces" do  
    cl = owner.contact_list
    cl.accounts << contact1
    expect(cl.accounts.count).to eq(1)
    expect {
      cl.accounts << contact1
    }.to raise_error(ActiveRecord::RecordInvalid, /ya está en la lista de contactos/)
    expect(cl.accounts.count).to eq(1)
  end
  end

  describe "Asociaciones" do
    it "pertenece a una cuenta" do
      expect(owner.contact_list.account).to eq(owner)
    end

    it "tiene muchas cuentas a través de contact_list_accounts" do
      cl = owner.contact_list
      cl.accounts << contact1
      cl.accounts << contact2
      expect(cl.accounts).to include(contact1, contact2)
    end
  end
end 