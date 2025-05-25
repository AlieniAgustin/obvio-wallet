require 'sinatra/base'
require_relative '../models/user'

class RegisterController < ApplicationController
  set :views, File.expand_path('../../views', __FILE__) #Para que encuentre al register correctamente cuando centralize con el register_controller
  get '/register' do
    erb :register
  end

  post '/register' do

    @user = User.new(
      name: params[:name],
      lastname: params[:lastname],
      dni: params[:dni],
      birth_date: params[:birth_date],
      email: params[:email],
      phone_number: params[:phone_number],
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