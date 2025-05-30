require 'sinatra/base'

class DashboardController < Sinatra::Base
  set :views, File.expand_path('../../views', __FILE__) #Para que encuentre al register correctamente cuando centralize con el register_controller
  set :public_folder, File.expand_path('../public', __FILE__)
  
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

  get '/dashboard/opciones-info-personal' do
    erb :'dashboard/opciones-info-personal', layout: :'dashboard/layout'
  end

  get '/dashboard/opciones-info-cuenta' do
    erb :'dashboard/opciones-info-cuenta', layout: :'dashboard/layout'
  end


  get '/dashboard/pago' do
    erb :'dashboard/pago', layout: :'dashboard/layout'
  end

  get '/dashboard/receipt' do 
    erb :'dashboard/receipt', layout: :'dashboard/layout'
  end
end

