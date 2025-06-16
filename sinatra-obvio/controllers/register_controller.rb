require 'sinatra/base'
require_relative '../models/user'

class RegisterController < Sinatra::Base
  # Configuracion de las sesiones
  enable :sessions
  set :session_secret, 'clave-top-secret'

  set :views, File.expand_path('../../views', __FILE__)

  helpers do
		def current_user
			@current_user ||= User.find(session[:user_id]) if session[:user_id]
		end

		def logged_in?
			!!current_user
		end
  end

  get '/register' do
    if logged_in?
      redirect '/dashboard'
    else
      erb :'main/register', layout: :'main/layout'
    end
  end


  post '/register' do
    if params[:password] != params[:confirmP]
      @error_messages = "Las contraseñas no coinciden"
      return erb :'main/register', layout: :'main/layout'
    end
    
    @user = User.new(
      first_name: params[:first_name].strip,
      last_name: params[:last_name].strip,
      dni: params[:dni].strip,
      address: params[:address].strip,
      email: params[:email].strip,
      password: params[:password]
    )

    if @user.save
      session[:user_id] = @user.id
      redirect to('/dashboard')
    else
        puts @user.errors.full_messages
        @error_messages = "Error al registrar usuario"
        erb :'main/register', layout: :'main/layout'
    end
  end

end

