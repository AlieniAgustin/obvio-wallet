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

    # Convierte una cantidad de plata (en centavos) a un string con dos decimales
    # Se tiene que usar cada vez que queramos mostrar un balance en alguna view
    def amount_format(balance)
      format('%.2f', balance / 100.0)
    end

    def toCents(balance)
      balance * 100
    end

    # Para mostrar campos de tipo Date en las views en formato AAAA-MM-DD
    def format_date(datetime)
      datetime.strftime("%Y-%m-%d")
    end 

    # Para mostrar campos de tipo Time en las views en formato HH:MM
    def format_time(datetime)
      datetime.strftime("%H:%M")
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

  # Solo accesible con una cuenta de destino como parametro
  get '/dashboard/pago/:target_account_id' do
    
    # Buscamos la cuenta destino por el id pasado como parametro
    @target_account = Account.find_by(id: params[:target_account_id])

    if @target_account.nil?
      redirect '/dashboard/contactos'
    end

    # Si la cuenta destino es la misma que la del usuario, redirigimos a contactos
    if @target_account.id == current_account.id
      redirect '/dashboard/contactos'
    end

    # Si llegamos aca, todo esta bien. Mostramos el formulario de pago
    erb :'dashboard/pago', layout: :'dashboard/layout'
  end

  post '/dashboard/pago' do 
    amount_str = params[:amount] # Obtiene de los parametros del form la cantidad (dada como un string en pesos)
    amount_str = amount_str.gsub(',', '.') # Convertimos comas a puntos (algunos navegadores te dejan poner , para indicar puntos decimales, pero rompe todo en ruby)
    amount_cents = (amount_str.to_f * 100).round # Convertimos a float y multiplicamos por 100 para trabajar con centavos. Redondeamos para evitar problemas de los float

    target_account = Account.find_by(id: params[:target_account_id])
    if target_account.nil?
      session[:error] = "Cuenta destino no encontrada"
      return redirect "/dashboard/contactos"
    end

    if target_account.id == current_account.id
      session[:error] = "No te podes transferir a vos mismo"
      return redirect "/dashboard/contactos"
    end 

    if amount_cents <= 0
      session[:error] = "Monto invalido"
      return redirect "/dashboard/pago/#{params[:target_account_id]}"
    end
    
    if amount_cents > current_account&.balance
      session[:error] = "Fondos insuficientes"
      return redirect "/dashboard/pago/#{params[:target_account_id]}"
    end

    last_transaction_number = Transaction.maximum(:transaction_number) || 0
    new_transaction_number = last_transaction_number + 1

    transaction = Transaction.new(
      transaction_number: new_transaction_number,
      date: Date.today,
      time: Time.now,
      amount: amount_cents,
      description: "Pago a #{target_account&.user.first_name} #{target_account&.user.last_name}",
      reason: "-",
      source_account_id: current_account.id,
      target_account_id: target_account.id
    )

    if transaction.save
      redirect "/dashboard/receipt/#{transaction.transaction_number}"
    else 
      session[:error] = "No se pudo realizar la transferencia"
      redirect "/dashboard/contactos"
    end
  end

  get '/dashboard/receipt/:transaction_number' do 
    @transaction = Transaction.find_by(transaction_number: params[:transaction_number])
    
    if @transaction.nil?
      redirect "/dashboard/home"
    end 

    source_account = @transaction.source_account
    target_account = @transaction.target_account

    # Solo dejamos ver el receipt si lo quiere ver alguna de las cuentas involucradas
    unless current_account && (current_account.id == source_account.id || current_account.id == target_account.id)
      redirect "/dashboard/home"
    end 

    erb :'dashboard/receipt', layout: :'dashboard/layout'
  end
end

