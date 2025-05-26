require 'sinatra/base'
require_relative '../models/user'



class LogInController < Sinatra::Base
  set :views, File.expand_path('../../views', __FILE__)

  get '/login' do
    erb :'main/login', layout: :'main/layout'
  end

end

