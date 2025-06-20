require 'spec_helper'

RSpec.describe LogInController, type: :controller do
  include Rack::Test::Methods

  def app
    LogInController.new
  end

  let!(:user) do
    User.create!(
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: '12345678',
      address: 'San Martin 250',
      email: 'pepe@gmail.com',
      password: 'secreta123'
    )
  end

  describe 'POST /login' do
    context 'cuando los datos son correctos' do
      it 'redirige al dashboard' do
        post '/login', email: 'pepe@gmail.com', password: 'secreta123'
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to end_with('/dashboard')
      end
    end

    context 'cuando la contraseña es incorrecta' do
      it 'muestra un mensaje de error' do
        post '/login', email: 'pepe@gmail.com', password: 'incorrecta'
        expect(last_response.body).to include('contraseña incorrecta')
      end
    end

    context 'cuando el email no existe' do
      it 'muestra un mensaje de error' do
        post '/login', email: 'fulano@gmail.com', password: 'cualquiera'
        expect(last_response.body).to include('El email no está registrado')
      end
    end
  end
end
