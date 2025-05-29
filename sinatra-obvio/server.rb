  require 'bundler/setup'
  require 'sinatra'
  require 'sinatra/activerecord'
  require 'sinatra/reloader' if Sinatra::Base.environment == :development
  require_relative 'models/user'
  require_relative 'models/account'
  require_relative 'models/transaction'
  require_relative 'models/contact_list'
  require_relative 'models/contact_list_account'
  require_relative 'models/monthly_summary'
  require_relative 'models/receipt'

  set :views, File.expand_path('../views', __FILE__)
  set :public_folder, File.expand_path('../public', __FILE__)

  class App < Sinatra::Application
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

    # Seccion web principal


    get '/' do
      erb :'main/landing', layout: :'main/layout'
    end

    get '/login' do
      erb :'main/login', layout: :'main/layout'
    end

    get '/register' do
      erb :'main/register', layout: :'main/layout'
    end

    get '/dashboard' do 
      erb :'dashboard/home', layout: :'dashboard/layout'
    end 

    get '/dashboard/home' do
      erb :'dashboard/home', layout: :'dashboard/layout'
    end

    get '/dashboard/movimientos' do
      erb :'dashboard/movimientos', layout: :'dashboard/layout'
    end 

    get '/dashboard/resumen' do 
      erb :'dashboard/resumen', layout: :'dashboard/layout'
    end 

    get '/dashboard/cargar' do
      erb :'dashboard/cargar', layout: :'dashboard/layout'
    end 

    get '/dashboard/contactos' do 
      erb :'dashboard/contactos', layout: :'dashboard/layout'
    end 

    get '/dashboard/vaquitas' do 
      erb :'dashboard/vaquitas', layout: :'dashboard/layout'
    end 

    get '/dashboard/opciones' do
      erb :'dashboard/opciones', layout: :'dashboard/layout'
    end

    get '/dashboard/pago' do 
      erb :'dashboard/pago', layout: :'dashboard/layout'
    end

    get '/dashboard/receipt' do
      erb :'dashboard/receipt', layout: :'dashboard/layout'
    end

    error 404 do 
      erb :'main/404', layout: :'main/layout'
    end

  end
