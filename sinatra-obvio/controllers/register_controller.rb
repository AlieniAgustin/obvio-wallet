require 'sinatra/base'
require_relative '../models/user'



class RegisterController < Sinatra::Base
  set :views, File.expand_path('../../views', __FILE__)

  get '/register' do
    erb :'main/register', layout: :'main/layout'
  end


  post '/register' do

    if params[:password] != params[:confirmP]
      @error_message = "Las contraseñas no coinciden"
      return erb :register
    end
    
    @user = User.new(
      first_name: params[:first_name],
      last_name: params[:last_name],
      dni: params[:dni],
      address: params[:address],
      email: params[:email],
      password: params[:password]
    )

    if @user.save
      redirect to('/login')
    else
       puts @user.errors.full_messages
        @error_message = "Error al registrar usuario"
        erb :register
    end

  end
end

