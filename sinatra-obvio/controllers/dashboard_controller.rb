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
      datetime.in_time_zone('America/Argentina/Buenos_Aires').strftime("%Y-%m-%d")
    end 

    # Para mostrar campos de tipo Time en las views en formato HH:MM
    def format_time(datetime)
      datetime.in_time_zone('America/Argentina/Buenos_Aires').strftime('%H:%M')    
    end
    
  end
  
  # Esto hace que cada vez que tratamos de entrar a alguna pagina del dashboard ejecute require_login
  before '/dashboard*' do
    require_login
  end

  get '/dashboard' do 
    redirect '/dashboard/home'
  end 

  get '/dashboard/home' do
    @recent_transactions = current_account.recent_transactions
    erb :'dashboard/home', layout: :'dashboard/layout'
  end

  get '/dashboard/movimientos' do
    erb :'dashboard/movimientos', layout: :'dashboard/layout'
  end 

  get '/dashboard/cargar' do
    erb :'dashboard/cargar', layout: :'dashboard/layout'
  end 

  post '/dashboard/cargar' do 
    amount = toCents(params[:amount].to_i)
    current_account.balance += amount
    current_account.save
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
      session[:error] = "Identifier required"
      redirect '/dashboard/contactos'
    end
    
    # Busca el contacto por cvu o alias
    contact_account = Account.find_by(cvu: contact_identifier) || 
                     Account.find_by(alias: contact_identifier)
    
    if contact_account.nil?
      # Manejo de errores - Si el contacto no existe, lo dice
      session[:error] = "No se encontró una cuenta con los datos dados."
      redirect '/dashboard/contactos'
    end
    
    # Chequea si el id del contacto no es el mismo que el del contacto actual
    if contact_account.id == current_account.id
      session[:error] = "No te podés agregar a vos mismo como contacto."
      redirect '/dashboard/contactos'
    end
    
    # Chequea si el contacto ya existe
    if current_account.contact_list.contact_list_accounts.any? { |cla| cla.account_id == contact_account.id }
      session[:error] = "El contacto ingresado ya está en la lista."
      redirect '/dashboard/contactos'
    end
    
    # Añade el contacto a la lista de contactos
    begin
      ContactListAccount.create!(
        contact_list: current_account.contact_list,
        account: contact_account
      )
      session[:success] = "Contacto agregado exitosamente."
      redirect '/dashboard/contactos'
    rescue => e
      puts "Error adding contact: #{e.message}"
      session[:error] = "Error al agregar el contacto"
      redirect '/dashboard/contactos'
    end
  end

  get '/dashboard/vaquitas' do 
    created = current_account.created_vaquitas.where(status: 'active')
    contributed = current_account.contributed_vaquitas.where(status: 'active')
    @vaquitas = (created + contributed).uniq
    erb :'dashboard/vaquitas', layout: :'dashboard/layout'
  end 

  post '/dashboard/vaquitas/crear' do 
    name = params[:name].strip
    description = params[:description].strip
    goalString = params[:goal]
    goalCents = (goalString.to_f * 100).round

    if name.empty? || description.empty?
      session[:error] = "Datos incompletos"
      redirect '/dashboard/vaquitas'
    end 

    if goalCents <= 0
      session[:error] = "Monto objetivo inválido"
      redirect '/dashboard/vaquitas'
    end 

    last_vaquita_id = Vaquita.maximum(:idVaquita) || 0
    new_vaquita_id = last_vaquita_id + 1

    vaquita = Vaquita.new(
      idVaquita: new_vaquita_id,
      current_amount: 0,
      creator_account_id: current_account.id,
      status: "active",
      goal: goalCents,
      name: name,
      description: description
    )

    if vaquita.save
      session[:success] = "Vaquita creada exitosamente"
    else 
      session[:error] = "Error al crear la vaquita"
    end 

    redirect "/dashboard/vaquitas/:#{new_vaquita_id}"
  end 
  
  
  post '/dashboard/vaquitas/buscar' do 
    vaquita_id = params[:vaquita_id].strip

    if vaquita_id.nil? || vaquita_id.empty?
      session[:error] = "Se necesita el ID de la vaquita"
      redirect '/dashboard/vaquitas'
    end

    vaquita = Vaquita.find_by(idVaquita: vaquita_id)
    
    if vaquita
      created = current_account.created_vaquitas.where(status: 'active')
      contributed = current_account.contributed_vaquitas.where(status: 'active')
      @vaquitas = (created + contributed).uniq
      
      if @vaquitas.any? {|v| v.idVaquita == vaquita_id.to_i}
        session[:error] = "La vaquita ya está en la lista"
        redirect '/dashboard/vaquitas'
      else 
          redirect "/dashboard/vaquitas/#{vaquita.idVaquita}"
      end
    else
      session[:error] = "No se encontro una vaquita con ese ID"
      redirect '/dashboard/vaquitas'
    end

  end

  get '/dashboard/vaquitas/:id' do 
    @vaquita = Vaquita.find_by(idVaquita: params[:id])
    if @vaquita.nil?
      session[:error] = "Vaquita no encontrada"
      redirect '/dashboard/vaquitas'
    end
    if @vaquita.status != 'active'
      session[:error] = "Esa vaquita no está activa"
      redirect '/dashboard/vaquitas'
    end
    erb :'dashboard/vaquita', layout: :'dashboard/layout'
  end 

  # post '/dashboard/vaquitas/:id/aportar'

  # end

  # post '/dashboard/vaquitas/:id/eliminar'

  # end


  post '/dashboard/vaquitas/aportar' do

    vaquita_id = params[:idVaquita].to_i # Convertir id a entero
    amount_str = params[:monto]&.gsub(',', '.') # Comas a puntos
    amount_cents = (amount_str.to_f * 100).round # Transformar a centavos

    # Validar datos
    if vaquita_id <= 0 || amount_cents <= 0 
      session[:error] = "Datos inválidos"
      redirect '/dashboard/vaquitas'
    end

    # Buscar vaquita por id
    vaquita = Vaquita.find_by(idVaquita: vaquita_id)
    if vaquita.nil?
      session[:error] = "Vaquita no encontrada"
      redirect '/dashboard/vaquitas'
    end

    if vaquita.status != 'active'
      session[:error] = "La vaquita no está activa"
      redirect '/dashboard/vaquitas'
    end

    # Verificar que el usuario tenga saldo suficiente
    if current_account.balance < amount_cents
      session[:error] = "Fondos insuficientes"
      redirect "/dashboard/vaquitas/#{vaquita_id}"
    end

    if vaquita.current_amount + amount_cents > vaquita.goal 
      session[:error] = "No podes hacer un aporte que exceda el monto objetivo de la vaquita"
      redirect "/dashboard/vaquitas/#{vaquita_id}"
    end

    begin
      ActiveRecord::Base.transaction do
        # Descontar al usuario
        current_account.update!(balance: current_account.balance - amount_cents)
        
        existing_contribution = Contribution.find_by(account_id: current_account.id, vaquita_id: vaquita_id)

        if existing_contribution
          existing_contribution.update!(amount: existing_contribution.amount + amount_cents)
        else
          new_contribution_id = (Contribution.maximum(:idContribution) || 0) + 1
          Contribution.create!(
            account_id: current_account.id,
            vaquita_id: vaquita_id,
            idContribution: new_contribution_id,
            amount: amount_cents
          )
        end

        session[:success] = "Aporte realizado exitosamente"
      end
    rescue => e
      puts "Error aportando a vaquita: #{e.message}"
      session[:error] = "No se pudo realizar el aporte"
    end

    redirect "/dashboard/vaquitas/#{vaquita_id}"
  end

  post '/dashboard/vaquitas/retirarAporte' do
    vaquita_id = params[:idVaquita].to_i
    monto_retiro_str = params[:montoRetiro]&.gsub(',', '.')
    monto_retiro_cents = (monto_retiro_str.to_f * 100).round

    # Validar monto mayor a cero
    if monto_retiro_cents <= 0
      session[:error] = "El monto a retirar debe ser mayor a cero."
      redirect "/dashboard/vaquitas/#{vaquita_id}"
    end

    # Buscar la vaquita por ID 
    vaquita = Vaquita.find_by(idVaquita: vaquita_id)
    if vaquita.nil?
      session[:error] = "Vaquita no encontrada."
      redirect "/dashboard/vaquitas"
    end

    # Validar que la vaquita este activa 
    if vaquita.status != 'active'
      session[:error] = "No se puede retirar de una vaquita inactiva."
      redirect "/dashboard/vaquitas/#{vaquita_id}"
    end

    # Buscar la contribución del usuario en esa vaquita
    contribution = Contribution.find_by(account_id: current_account.id, vaquita_id: vaquita_id)
    if contribution.nil?
      session[:error] = "No tenés aportes en esta vaquita."
      redirect "/dashboard/vaquitas/#{vaquita_id}"
    end

    # Validar que el monto a retirar no sea mayor a lo aportado
    if monto_retiro_cents > contribution.amount
      session[:error] = "No podés retirar más de lo que aportaste."
      redirect "/dashboard/vaquitas/#{vaquita_id}"
    end

    begin
      ActiveRecord::Base.transaction do
        # Acreditar saldo al usuario
        current_account.update!(balance: current_account.balance + monto_retiro_cents)

        if monto_retiro_cents == contribution.amount
          # Si retira todo, eliminar la contribución
          contribution.destroy!
        else
          # Si retira una parte, restar del amount
          contribution.update!(amount: contribution.amount - monto_retiro_cents)
        end

        session[:success] = "Retiro exitoso de $#{amount_format(monto_retiro_cents)}."
      end
    rescue => e
      puts "Error al retirar aporte: #{e.message}"
      session[:error] = "Ocurrió un error al procesar el retiro."
    end

    # Redirigir nuevamente a la pagina de la vaquita
    redirect "/dashboard/vaquitas/#{vaquita_id}"
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
    metodo = params[:metodo_pago]
    # Buscamos la cuenta destino por el id pasado como parametro
    @target_account = Account.find_by(id: params[:target_account_id])

    if @target_account.nil?
      session[:error] = "Cuenta destino no encontrada"
      redirect '/dashboard/contactos'
    end

    # Si la cuenta destino es la misma que la del usuario, redirigimos a contactos
    if @target_account.id == current_account.id
      session[:error] = "No te podes transferir a vos mismo"
      redirect '/dashboard/contactos'
    end

    # Si llegamos aca, todo esta bien. Mostramos el formulario de pago
    if metodo == "cuenta"
      erb :'dashboard/pago', layout: :'dashboard/layout'
    else  
      erb :'dashboard/pagoConVaquita', layout: :'dashboard/layout'
  
    end
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

get '/dashboard/resumen' do
  # Mostrar resumen del mes y año actual
  today = Date.today
  redirect to("/dashboard/resumen/#{today.year}/#{today.month}")
end

get '/dashboard/resumen/:year/:month' do
  # Parseo parámetros
  @year = params[:year].to_i
  @month = params[:month].to_i

  # Validar mes y año (mínimo 1 y máximo 12 para mes)
  unless @month.between?(1,12) && @year > 0
    redirect '/dashboard/resumen'
  end

  # Fecha base del mes
  date = Date.new(@year, @month, 1) rescue halt(400, "Fecha inválida")

  # No permitir ver meses futuros (comparar con hoy)
  if date > Date.today.beginning_of_month
    redirect to("/dashboard/resumen/#{Date.today.year}/#{Date.today.month}")
  end

  # Calcular meses anterior y siguiente para los links
  prev_date = date << 1  # Un mes antes
  next_date = date >> 1  # Un mes después

  # No permitir mes siguiente después del actual
  if next_date > Date.today.beginning_of_month
    next_date = nil
  end

  @prev_year = prev_date.year
  @prev_month = prev_date.month

  @next_year = next_date&.year
  @next_month = next_date&.month

  # Consultar transacciones del usuario para ese mes
  start_date = date
  end_date = (date >> 1) - 1  # Último día del mes

  @transactions = current_user.account.transactions
                     .where(date: start_date..end_date)
                     .order(date: :desc, time: :desc)

  # Sumar ingresos y egresos
  @income_total = amount_format(@transactions.select { |t| t.target_account_id == current_user.account.id }
                               .sum(&:amount))
  @expense_total = amount_format(@transactions.select { |t| t.source_account_id == current_user.account.id }
                                .sum(&:amount))

  erb :'dashboard/resumen', layout: :'dashboard/layout'
  end

end
