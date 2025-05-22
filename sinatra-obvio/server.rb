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
  
end
