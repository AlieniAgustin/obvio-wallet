require 'spec_helper'

RSpec.describe User, type: :model do
  before(:each) do
    # Limpia la DB para evitar problemas con UNIQUE
    User.destroy_all
    Account.destroy_all
  end

  it 'es válido con todos los atributos obligatorios' do
    user = User.new(
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: '87654321',
      address: 'Calle 456',
      email: 'pepe@example.com',
      password: '123456'
    )
    expect(user).to be_valid
  end

  it 'no es válido sin email' do
    user = User.new(
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: '87654321',
      address: 'Calle 456',
      email: nil,
      password: '123456'
    )
    expect(user).not_to be_valid
  end

  it 'no es válido con email inválido' do
    user = User.new(
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: '87654321',
      address: 'Calle 456',
      email: 'ana#mail.com',
      password: '123456'
    )
    expect(user).not_to be_valid
  end

  it 'no es válido sin dni' do
    user = User.new(
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: nil,
      address: 'Calle 456',
      email: 'pepe@example.com',
      password: '123456'
    )
    expect(user).not_to be_valid
  end

  it 'no es válido con dni de longitud incorrecta' do
    user = User.new(
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: '1234567', # 7 dígitos
      address: 'Calle 456',
      email: 'pepe@example.com',
      password: '123456'
    )
    expect(user).not_to be_valid
  end

  it 'no permite emails duplicados' do
    User.create!(
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: '12345678',
      address: 'Calle 456',
      email: 'pepe@example.com',
      password: '123456'
    )
    user2 = User.new(
      first_name: 'Juan',
      last_name: 'Perez',
      dni: '87654321',
      address: 'Calle 789',
      email: 'pepe@example.com',  # email repetido
      password: 'abcdef'
    )
    expect(user2).not_to be_valid
  end

  it 'crea una cuenta automáticamente al crear el usuario' do
    user = User.create!(
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: '87654321',
      address: 'Calle 456',
      email: 'ana2@example.com',
      password: '123456'
    )
    expect(user.account).not_to be_nil
    expect(user.account.balance).to eq(1_000_000)
    expect(user.account.cvu.length).to eq(22)
    expect(user.account.alias).to include("#{user.first_name.downcase}.#{user.last_name.downcase}")
  end

  it 'autentica con la contraseña correcta' do
    user = User.create!(
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: '87654322',
      address: 'Calle 456',
      email: 'ana3@example.com',
      password: '123456'
    )
    expect(user.authenticate('123456')).to eq(user)
    expect(user.authenticate('wrongpass')).to be_falsey
  end
end
