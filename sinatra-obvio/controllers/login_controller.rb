require 'sinatra/base'
require_relative '../models/user'



class LogInController < Sinatra::Base
  set :views, File.expand_path('../../views', __FILE__)

  get '/login' do
    erb :'main/login', layout: :'main/layout'
  end

	post '/login' do
		user = User.find_by(email: params[:email])

		if user && user.authenticate(params[:password])
			# Autenticación exitosa
			redirect to('/dashboard') # o donde quieras redirigir
		else
			# Falló la autenticación
			@error_message = "Email o contraseña incorrectos"
			erb :'main/login', layout: :'main/layout'
  end
end


end

