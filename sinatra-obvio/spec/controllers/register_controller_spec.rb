require 'spec_helper'
require 'rack/test'

RSpec.describe RegisterController, type: :controller do
  include Rack::Test::Methods

  def app
    RegisterController.new
  end

  let(:valid_params) do
    {
      first_name: 'Pepe',
      last_name: 'McPepe',
      dni: '12345678',
      address: 'San Martin 250',
      email: 'pepe@example.com',
      password: 'password123',
      confirmP: 'password123'
    }
  end

  describe 'GET /register' do
    context 'cuando el usuario no está logueado' do
      it 'muestra el formulario de registro' do
        get '/register'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Registrarse')
      end
    end

    context 'cuando el usuario está logueado' do
      before do
        user = User.create!(
          first_name: 'Fulano',
          last_name: 'Fulanez',
          dni: '87654321',
          address: 'Av. Italia 200',
          email: 'fulano@example.com',
          password: 'pass123'
        )
        env 'rack.session', { user_id: user.id }
      end

      it 'redirecciona a /dashboard' do
        get '/register'
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/dashboard')
      end
    end
  end

  describe 'POST /register' do
    context 'cuando los datos son válidos' do
      it 'crea un usuario y redirige al dashboard' do
        post '/register', valid_params
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/dashboard')
        expect(User.find_by(email: 'pepe@example.com')).not_to be_nil
      end
    end

    context 'cuando las contraseñas no coinciden' do
      it 'renderiza el formulario con error' do
        post '/register', valid_params.merge(confirmP: 'otra')
        expect(last_response.body).to include('Las contraseñas no coinciden')
      end
    end

    context 'cuando el email ya está registrado' do
    before do
        User.create!(valid_params.except(:confirmP))
    end

    it 'renderiza el formulario con error de email' do
        post '/register', valid_params.merge(dni: '99999999')
        expect(last_response.body).to include('ya está registrado')
    end
    end

    context 'cuando el dni ya está registrado' do
      before do
        User.create!(valid_params.except(:confirmP))
      end

      it 'renderiza el formulario con error de dni' do
        post '/register', valid_params.merge(email: 'otro@example.com')
        expect(last_response.body).to include('El dni ya está registrado')
      end
    end
  end
end
