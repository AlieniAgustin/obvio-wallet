require_relative '../spec_helper'

RSpec.describe User, type: :model do
  it 'es válido con todos los atributos obligatorios' do
    user = User.new(
      first_name: 'Juan',
      last_name: 'Pérez',
      dni: '12345678',
      address: 'Calle 123',
      email: 'juan@example.com',
      password: 'secreto'
    )
    expect(user).to be_valid
  end

  it 'no es válido sin email' do
    user = User.new(email: nil)
    user.validate
    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'autentica con la contraseña correcta' do
    user = User.create!(
      first_name: 'Ana',
      last_name: 'García',
      dni: '87654321',
      address: 'Calle 456',
      email: 'ana@example.com',
      password: '123456'
    )
    expect(user.authenticate('123456')).to eq(user)
    expect(user.authenticate('wrong')).to be_falsey
  end
end
