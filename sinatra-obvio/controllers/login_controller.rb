require 'sinatra/base'
require_relative '../models/user'

class LogInController < Sinatra::Base
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

	get '/login' do
		if logged_in?
			redirect '/dashboard'
		else
			erb :'main/login', layout: :'main/layout'
		end
	end

	post '/login' do
		user = User.find_by(email: params[:email])
		if user && user.authenticate(params[:password])
			# Autenticación exitosa
			session[:user_id] = user.id
			redirect '/dashboard'
		else
			# Falló la autenticación
			@error_message = "Email o contraseña incorrectos"
			erb :'main/login', layout: :'main/layout'
		end
	end
end

