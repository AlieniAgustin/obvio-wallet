# Kickstart: Building a Sinatra Application

Guía para crear una aplicación web con Sinatra, incluyendo recarga en vivo, Docker, registro de eventos, ActiveRecord y pruebas con RSpec. Sigue estos seis pasos para crear un entorno de desarrollo robusto.

## Step 1: Basic Sinatra Setup

Create a minimal Sinatra application with a Gemfile, server file, and Rack configuration.

### Gemfile

```ruby
# Esta línea indica la versión de Ruby que se espera o se recomienda para este proyecto.
# En este caso, es la versión 3.2.2. Aunque esta es una convención común,
ruby '3.2.2'

# Esta línea es fundamental en cualquier Gemfile.
# Indica el origen de donde Bundler (la herramienta que lee y procesa el Gemfile)
source "https://rubygems.org"

# Declara las dependencias del proyecto (gemas requeridas).
# Cada línea con `gem` especifica una gema y, opcionalmente, su versión o restricciones.

# Gema: sinatra
# Sinatra es un framework ligero para construir aplicaciones web en Ruby.
# La restricción '~> 4.1' indica que se usará la versión 4.1.x (cualquier versión 4.1 con parches, pero no 4.2 o superior).
# Esto garantiza compatibilidad con las funcionalidades esperadas sin introducir cambios mayores imprevistos.
gem 'sinatra', '~> 4.1'

# Gema: rackup
# `rackup` es una herramienta de línea de comandos incluida en la gema `rack`.
# Se usa para iniciar servidores web compatibles con Rack, como el servidor de Sinatra.
# Al incluir esta gema, aseguramos que el comando `rackup` esté disponible para ejecutar el archivo `config.ru`.
# Nota: No se especifica una versión, por lo que Bundler usará la última versión estable disponible.
gem 'rackup'

# Gema: puma
# Puma es un servidor web concurrente y de alto rendimiento para aplicaciones Ruby/Rack.
# Es comúnmente usado con Sinatra por su velocidad y capacidad para manejar múltiples solicitudes simultáneamente.
gem 'puma', '~> 6.6'
```

### server.rb

```ruby
require 'sinatra/base'

# Define una clase 'App' que hereda de 'Sinatra::Application',
# convirtiéndola en una aplicación web Sinatra.
class App < Sinatra::Application
  # Define una ruta para solicitudes GET a la URL raíz ('/').
  get '/' do
    'Welcome'
  end
end
```

### config.ru

```ruby
require './server'
run App
```

### Start the Server

Run the server using Rackup:

```bash
bundle exec rackup -p 8000
```

Visit `http://localhost:8000` to see "Welcome".

## Step 2: Enable Live Reloading

Add live reloading for development using `sinatra-contrib`.

### Update Gemfile

Add the `sinatra-contrib` gem to your Gemfile

```ruby
# Incluye la gema sinatra-contrib, que proporciona extensiones útiles para Sinatra, como recarga automática (reloader), helpers y herramientas de desarrollo.
gem 'sinatra-contrib'
```

### Update server.rb

```ruby
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development

class App < Sinatra::Application
  configure :development do
    register Sinatra::Reloader
    after_reload do
      puts 'Reloaded...'
    end
  end

  get '/' do
    'Welcome'
  end
end
```

### Restart the Server

```bash
bundle exec rackup -p 8000
```

Make a change to `server.rb` and check the terminal for "Reloaded...".

## Step 3: Dockerize the Application

Containerize the application using Docker and Docker Compose.

### Dockerfile

```dockerfile
# Usa la imagen oficial de Ruby 3.2.2 como base.
FROM ruby:3.2.2

# Define variables de entorno para Bundler:
# - BUNDLE_PATH: Directorio donde se instalan las gemas.
# - BUNDLE_APP_CONFIG: Ubicación del archivo de configuración de Bundler.
# - RAILS_ENV: Establece el entorno como desarrollo.
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle/config \
    RAILS_ENV=development

# Establece /app como el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Copia Gemfile y Gemfile.lock para instalar dependencias primero (aprovecha caché de Docker).
COPY Gemfile Gemfile.lock ./

# Ejecuta bundle install para instalar las gemas especificadas en el Gemfile.
RUN bundle install

# Copia todo el contenido del proyecto al directorio /app.
COPY . .

# Expone el puerto 8000 para acceso externo.
EXPOSE 8000

# Define el comando predeterminado para iniciar el contenedor:
# - bundle exec: Ejecuta comandos en el contexto de las gemas instaladas.
# - rackup: Inicia el servidor Rack.
# - -o 0.0.0.0: Escucha en todas las interfaces de red.
# - -p 8000: Usa el puerto 8000.
# Busca automáticamente config.ru para iniciar la aplicación.
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8000"]
```

### docker-compose.yml

```yaml
# Define los servicios que componen la aplicación.
services:
  # Nombre del servicio: "app".
  app:
    # Configura la construcción del contenedor usando el Dockerfile en el directorio actual.
    build:
      context: .
    # Sobrescribe el comando por defecto del Dockerfile para desarrollo:
    # - bundle exec rackup: Ejecuta el servidor Rack.
    # - -o 0.0.0.0: Escucha en todas las interfaces de red.
    # - -p 8000: Usa el puerto 8000.
    # - -I .: Añade el directorio actual a la ruta de carga de Ruby.
    # - --debug: Habilita salida detallada.
    # - --require sinatra/reloader: Carga el reloader de Sinatra para recarga en caliente.
    command: bundle exec rackup -o 0.0.0.0 -p 8000 -I . --debug --require sinatra/reloader
    # Mapea el puerto 8000 del contenedor al puerto 8000 del host.
    ports:
      - '8000:8000'
    # Monta el directorio actual del host en /app del contenedor, permitiendo reflejar cambios en tiempo real.
    volumes:
      - .:/app
```

### Build and Run

```bash
docker compose build
docker compose up app
```

Access the app at `http://localhost:8000`.

## Step 4: Add Logging

Enable logging to monitor application events.

### Update server.rb

```ruby
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'logger'

class App < Sinatra::Application

  configure :development do
    enable :logging
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if development?
    set :logger, logger

    register Sinatra::Reloader
    after_reload do
      logger.info 'Reloaded!!!'
    end
  end

  get '/' do
    'Welcome'
  end
end
```

### Check Logs

Restart the server with `docker compose up app` and modify `server.rb` to see "Reloaded!!!" in the logs.

## Step 5: Integrate ActiveRecord

Add a SQLite database using ActiveRecord for data persistence.

### Update Gemfile

```ruby
# Gema: sinatra-activerecord
# Integra ActiveRecord (un ORM de Ruby) con Sinatra.
# Permite usar modelos y manejar bases de datos relacionales fácilmente
gem 'sinatra-activerecord'

# Gema: sqlite3
# Proporciona una interfaz para usar SQLite, una base de datos ligera y sin servidor.
# Es ideal para desarrollo o aplicaciones pequeñas, ya que almacena datos en un solo archivo.
gem 'sqlite3'

# Gema: rake
# Herramienta para automatizar tareas en Ruby (similar a Make).
# En este contexto, se usa para ejecutar tareas de base de datos, como migraciones con ActiveRecord (ej. `rake db:migrate`).
gem 'rake'
```

### Rakefile

```ruby
require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require "./server"
  end
end
```

### Create a file to configure the DB

# config/database.yml

```
default: &default
  adapter: sqlite3
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: db/wallet_development.sqlite3

test:
  <<: *default
  database: db/test.sqlite3

production:
  <<: *default
  database: db/production.sqlite3
```

### Check rake is working

```bash
docker compose exec app bundle exec rake -T
```

### Create DB

```bash
docker compose exec app bundle exec rake db:create
```

### Create a migration to create the table

```bash
bundle exec rake db:create_migration NAME=create_users
```

The migration file should looks like this:

```ruby
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name

      t.timestamps
    end
  end
end
```

### Run the migration

```bash
docker compose exec app bundle exec rake db:migrate
```

### Create the model to associate with the Table

```ruby
# models/user.rb
class User < ActiveRecord::Base
end
```

### Update server.rb

```ruby
require 'sinatra/activerecord'
require_relative 'models/user'
```

Now you can use the User model to interact with the database.

### Useful commands

Enter to a ruby console with the app loaded to test models for example:

```bash
$ docker compose exec app bundle exec irb -I. -r server.rb
```

# Sqlite3 commands

```bash
sqlite db/wallet_development.sqlite3
  Este comando abre el archivo de base de datos wallet_development.sqlite3 en el cliente de SQLite. Cuando lo ejecutas, entrarás en el entorno interactivo de SQLite, donde puedes ejecutar otros comandos

.tables
  Este comando muestra todas las tablas que existen en la base de datos SQLite actual. 
.schema
  Este comando muestra el esquema completo de todas las tablas en la base de datos, es decir, las definiciones de las tablas y sus columnas.
.schema users --indent
```

## References

- [Sinatra Github](https://github.com/sinatra/sinatra)
- [Sinatra ActiveRecord](https://github.com/sinatra-activerecord/sinatra-activerecord)
- [Bundler](https://bundler.io/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)


## dac
podríamos hacer una carpeta "scripts" para tener alias de los comandos que usamos en el desarrollo