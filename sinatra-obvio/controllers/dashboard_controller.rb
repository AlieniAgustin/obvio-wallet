require 'sinatra/base'

class DashboardController < Sinatra::Base
  # Configuracion de las sesiones
  enable :sessions
  set :session_secret, 'clave-top-secret'

  set :views, File.expand_path('../../views', __FILE__) #Para que encuentre al register correctamente cuando centralize con el register_controller
  set :public_folder, File.expand_path('../public', __FILE__)

  helpers do
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    # Para obtener los datos de la cuenta del usuario en los erb (Por ejemplo, @current_account&.cvu)
    def current_account
      @current_account ||= current_user&.account if current_user
    end

    def logged_in?
      !!current_user
    end

    def require_login
      unless logged_in?
        redirect '/login'
      end
    end

    # Ayuda a verificar que la cuenta tenga una lista de contactos
    def ensure_contact_list
      if current_account && current_account.contact_list.nil?
        ContactList.create!(account: current_account)
        current_account.reload
      end
    end
  end
  
  # Esto hace que cada vez que tratamos de entrar a alguna pagina del dashboard ejecute require_login
  before '/dashboard*' do
    require_login
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

  # POST ruta que añade un nuevo contacto
  post '/dashboard/contactos' do
    ensure_contact_list  # Se asegura que la lista de contactos exista
    
    contact_identifier = params[:contact_identifier]&.strip
    
    if contact_identifier.nil? || contact_identifier.empty?
      # Manejo de error - Si el contacto no existe, lo anuncia
      redirect '/dashboard/contactos?error=identifier_required'
    end
    
    # Busca el contacto por cvu o alias
    contact_account = Account.find_by(cvu: contact_identifier) || 
                     Account.find_by(alias: contact_identifier)
    
    if contact_account.nil?
      # Manejo de errores - Si el contacto no existe, lo dice
      redirect '/dashboard/contactos?error=account_not_found'
    end
    
    # Chequea si el id del contacto no es el mismo que el del contacto actual
    if contact_account.id == current_account.id
      redirect '/dashboard/contactos?error=cannot_add_self'
    end
    
    # Chequea si el contacto ya existe
    if current_account.contact_list.contact_list_accounts.any? { |cla| cla.account_id == contact_account.id }
      redirect '/dashboard/contactos?error=contact_exists'
    end
    
    # Añade el contacto a la lista de contactos
    begin
      ContactListAccount.create!(
        contact_list: current_account.contact_list,
        account: contact_account
      )
      redirect '/dashboard/contactos?success=contact_added'
    rescue => e
      puts "Error adding contact: #{e.message}"
      redirect '/dashboard/contactos?error=database_error'
    end
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

