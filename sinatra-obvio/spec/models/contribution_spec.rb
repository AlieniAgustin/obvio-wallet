require 'spec_helper'

RSpec.describe Contribution, type: :model do
  before(:each) do
    Contribution.destroy_all
    Account.destroy_all
    Vaquita.destroy_all
    User.destroy_all

    @user = User.create!(
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: '12345678',
      address: 'Calle 123',
      email: 'pepe@example.com',
      password: 'password'
    )

    @account = @user.account

    @vaquita = Vaquita.create!(
      name: 'Cumple de Juan',
      description: 'Para el regalo de Juan',
      goal: 50000,
      current_amount: 0,
      creator_account_id: @account.id
    )
  end

  it 'es válida con atributos obligatorios' do
    contrib = Contribution.new(
      account: @account,
      vaquita: @vaquita,
      amount: 10000
    )
    expect(contrib).to be_valid
  end

  it 'no es válida sin monto' do
    contrib = Contribution.new(
      account: @account,
      vaquita: @vaquita,
      amount: nil
    )
    expect(contrib).not_to be_valid
  end

  it 'no es válida si el monto es 0 o negativo' do
    contrib = Contribution.new(
      account: @account,
      vaquita: @vaquita,
      amount: -100
    )
    expect(contrib).not_to be_valid
  end

  it 'no es válida sin cuenta asociada' do
    contrib = Contribution.new(
      vaquita: @vaquita,
      amount: 1000
    )
    expect(contrib).not_to be_valid
  end

  it 'no es válida sin vaquita asociada' do
    contrib = Contribution.new(
      account: @account,
      amount: 1000
    )
    expect(contrib).not_to be_valid
  end

  it 'no permite contribuciones duplicadas del mismo account a la misma vaquita' do
    # En el controller manejamos este caso actualizando el saldo de contribucion en vez de crear otra contribucion
    Contribution.create!(
      account: @account,
      vaquita: @vaquita,
      amount: 10000
    )

    contrib_dup = Contribution.new(
      account: @account,
      vaquita: @vaquita,
      amount: 20000
    )

    expect(contrib_dup).not_to be_valid
  end
end
