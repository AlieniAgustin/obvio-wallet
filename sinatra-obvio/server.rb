require 'bundler/setup'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader' if Sinatra::Base.environment == :development

require_relative 'controllers/register_controller'
require_relative 'controllers/dashboard_controller'
require_relative 'controllers/login_controller'

require_relative 'models/user'
require_relative 'models/account'
require_relative 'models/transaction'
require_relative 'models/contact_list'
require_relative 'models/contact_list_account'
require_relative 'models/monthly_summary'
require_relative 'models/receipt' 



class App < Sinatra::Application
  # Configuracion de las sesiones
  enable :sessions
  set :session_secret, 'clave-top-secret'

  # Configuracion de los directorios de las views y assets
  set :views, File.expand_path('../views', __FILE__)
  set :public_folder, File.expand_path('../public', __FILE__)

  configure :development do
    enable :logging
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if development?
    set :logger, logger
    register Sinatra::Reloader
    after_reload do
      logger.info 'Reloaded!!!'
    end
  end

  # Funciones auxiliares para trabajar con sesiones
  helpers do
    # Para obtener los datos del usuario actual en los erb (Por ejemplo, @current_user&.first_name)
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id] # Si existe current_user lo devuelve. Sino, lo busca en la base de datos
    end

    # Para controlar si un usuario esta logueado o no, y evitar el acceso a usuarios no logueados al dashboard
    def logged_in?
      !!current_user # !! convierte valores nil a False, valores validos a True
    end

    # Para mandar al usuario a loguearse cuando intente entrar al dashboard si no esta logueado
    def require_login
      unless logged_in?
        redirect '/login'
      end
    end
  end

  # Seccion web principal
  get '/' do
    erb :'main/landing', layout: :'main/layout'
  end

  error 404 do 
    erb :'main/404', layout: :'main/layout'
  end

  # Para cerrar sesión. Lo usamos en el <a> de logout del sidebar del dashboard
  get '/logout' do 
    session.clear # cerramos sesión
    redirect '/'
  end

  use LogInController
  use RegisterController
  use DashboardController
end
