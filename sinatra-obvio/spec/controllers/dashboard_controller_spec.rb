require_relative '../spec_helper'

RSpec.describe DashboardController do
  include Rack::Test::Methods

  def app
    DashboardController
  end

  let(:user) { User.create!(
    first_name: "Juan",
    last_name: "Perez", 
    email: "juan@example.com",
    dni: "12345678",
    address: "Calle 345",
    password: "password123"
  ) }
  let(:account) { user.account }
  let(:other_user) { User.create!(
        first_name: "Juana",
        last_name: "Hernandez",
        email: "juana@example.com", 
        dni: "87654321",
        address: "Sallorenzo 223",
        password: "password123"
      ) }
  let(:other_account) { other_user.account }

  before do
    # Add other_account to user's contact list
    ContactListAccount.create!(contact_list: account.contact_list, account: other_account)
  end

  describe "Autentificacion" do
    it "redirige a login cuando la cuenta no es autentificada" do
      get '/dashboard/home'
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/login')
    end

    it "permite el acceso cuando la cuenta esta autentificada" do
      # Simulate authenticated session by setting session directly
      get '/dashboard/home', {}, { 'rack.session' => { user_id: user.id } }
      expect(last_response.status).to eq(200)
    end
  end

  describe "Dashboard routes" do

    # Add this helper method to simulate authenticated requests
    def authenticated_session
      { 'rack.session' => { user_id: user.id } }
    end

    describe "GET /dashboard" do
      it "redirige a dashboard/home" do
        get '/dashboard', {}, authenticated_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/dashboard/home')
      end
    end
  end


end
