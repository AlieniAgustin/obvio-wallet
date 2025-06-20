require 'spec_helper'

RSpec.describe Vaquita, type: :model do
  let(:user) { User.create!(first_name: 'Roberto', last_name: 'Gomez', dni: '12345678', address: 'Calle Falsa 123', email: 'roberto@example.com', password: 'password123') }
  let(:account) { user.account }

  describe 'validaciones' do
    it 'es válida con atributos válidos' do
      vaquita = Vaquita.new(
        name: 'Cumpleaños',
        description: 'Regalo para Ana',
        goal: 50000,
        creator_account_id: account.id
      )
      expect(vaquita).to be_valid
    end

    it 'es inválida sin nombre' do
      vaquita = Vaquita.new(name: nil, description: 'desc', goal: 5000, creator_account_id: account.id)
      expect(vaquita).not_to be_valid
    end

    it 'es inválida sin descripción' do
      vaquita = Vaquita.new(name: 'nombre', description: nil, goal: 5000, creator_account_id: account.id)
      expect(vaquita).not_to be_valid
    end

    it 'es inválida sin goal' do
      vaquita = Vaquita.new(name: 'nombre', description: 'desc', goal: nil, creator_account_id: account.id)
      expect(vaquita).not_to be_valid
    end

    it 'es inválida con goal menor o igual a cero' do
      vaquita = Vaquita.new(name: 'nombre', description: 'desc', goal: 0, creator_account_id: account.id)
      expect(vaquita).not_to be_valid
    end

    it 'es inválida sin cuenta creadora' do
      vaquita = Vaquita.new(name: 'nombre', description: 'desc', goal: 5000, creator_account_id: nil)
      expect(vaquita).not_to be_valid
    end

    it 'es inválida con status inválido' do
      vaquita = Vaquita.new(name: 'nombre', description: 'desc', goal: 5000, creator_account_id: account.id, status: 'cerrada')
      expect(vaquita).not_to be_valid
    end
  end

  describe 'asociaciones' do
    it 'pertenece a un creador (Account)' do
      vaquita = Vaquita.create!(name: 'nombre', description: 'desc', goal: 5000, creator_account_id: account.id)
      expect(vaquita.creator).to eq(account)
    end

    it 'puede tener contribuciones y contributors' do
      vaquita = Vaquita.create!(name: 'nombre', description: 'desc', goal: 5000, creator_account_id: account.id)
      vaquita.contributions.create!(account: account, amount: 1000)
      expect(vaquita.contributions.count).to eq(1)
      expect(vaquita.contributors).to include(account)
    end
  end

  describe 'métodos de instancia' do
    let(:vaquita) {
      Vaquita.create!(
        name: 'Fiesta',
        description: 'Fin de año',
        goal: 20000,
        creator_account_id: account.id
      )
    }

    it '#current_amount devuelve 0 si no hay contribuciones' do
      expect(vaquita.current_amount).to eq(0)
    end

    it '#update_current_amount! suma correctamente los aportes' do
    second_user = User.create!(
        first_name: 'Pepe',
        last_name: 'McPepe',
        dni: '87654321',
        address: 'Calle 456',
        email: 'pepe@example.com',
        password: 'password123'
    )
    second_account = second_user.account

    vaquita.contributions.create!(account: account, amount: 5000)
    vaquita.contributions.create!(account: second_account, amount: 3000)

    total = vaquita.update_current_amount!
    expect(total).to eq(8000)
    expect(vaquita.reload.current_amount).to eq(8000)
    end

    it '#goal_reached? devuelve false si no se alcanzó el objetivo' do
      vaquita.contributions.create!(account: account, amount: 1000)
      vaquita.update_current_amount!
      expect(vaquita.goal_reached?).to be false
    end

    it '#goal_reached? devuelve true si se alcanza el objetivo' do
      vaquita.contributions.create!(account: account, amount: 25000)
      vaquita.update_current_amount!
      expect(vaquita.goal_reached?).to be true
    end

    it '#can_be_withdrawn? es true solo si está activa y se alcanzó el goal' do
      vaquita.update!(status: 'active')
      vaquita.contributions.create!(account: account, amount: 25000)
      vaquita.update_current_amount!
      expect(vaquita.can_be_withdrawn?).to be true
    end

    it '#percentage_complete calcula el porcentaje correctamente' do
      vaquita.contributions.create!(account: account, amount: 5000)
      vaquita.update_current_amount!
      expect(vaquita.percentage_complete).to eq(25.0)
    end
  end
end
