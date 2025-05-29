require 'sinatra/base'
require_relative '../models/user'



class RegisterController < Sinatra::Base
  set :views, File.expand_path('../../views', __FILE__)

  get '/register' do
    erb :'main/register', layout: :'main/layout'
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
      redirect to('/login')
    else
       puts @user.errors.full_messages
        @error_messages = "Error al registrar usuario"
        erb :'main/register', layout: :'main/layout'
    end

  end
end

