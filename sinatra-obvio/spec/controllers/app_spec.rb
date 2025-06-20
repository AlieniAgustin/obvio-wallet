require 'spec_helper'

RSpec.describe 'Landing page', type: :request do
  include Rack::Test::Methods

  def app
    App.new
  end

  describe 'GET /' do
    before { get '/' }

    it 'responde con éxito' do
      expect(last_response).to be_ok
    end

    it 'muestra el título principal' do
      expect(last_response.body).to include('¿Te puedo transferir?')
    end

    it 'muestra el subtítulo' do
      expect(last_response.body).to include('Todo lo que necesitás en una sola billetera virtual')
    end

    it 'tiene un botón para registrarse' do
      expect(last_response.body).to include('Unite a OBVIO')
      expect(last_response.body).to include('/register')
    end

    it 'muestra las características de la app' do
      expect(last_response.body).to include('Realizá transferencias al instante')
      expect(last_response.body).to include('Juntá plata con amigos')
      expect(last_response.body).to include('Conocé en qué gastás tu plata')
      expect(last_response.body).to include('Pagá en un click')
    end
  end

   describe 'GET a una ruta inexistente' do
    before { get '/ruta-que-no-existe' }

    it 'responde con 404' do
      expect(last_response.status).to eq(404)
    end

    it 'muestra el título del error' do
      expect(last_response.body).to include('Error 404')
    end

    it 'muestra el subtítulo de página no encontrada' do
      expect(last_response.body).to include('Página no encontrada')
    end

    it 'incluye un botón para volver al inicio' do
      expect(last_response.body).to include('Volver al inicio')
      expect(last_response.body).to include('href="/"')
    end
  end
end
