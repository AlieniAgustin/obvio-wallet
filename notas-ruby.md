
### --- Explicación de cómo manejarse en mi_app ---

## Estructura:

1. **Gemfile**: archivo que dice todas las dependencias/gemas que necesita la app para correr.  
   Cuando corres `bundle install` se fija en este archivo para instalarlo.

2. **Gemfile.lock**: es como el Gemfile pero "ejecutado".  
   Si todos estamos en Ubuntu, no hay que tocarlo.  
   Si alguno no está en Ubuntu, lo borra, y ejecuta nuevamente `bundle install`.

3. **server.rb**: similar a "main". Es de donde se setea la página.  
   Se muestra el mensaje de "hola mundo". Denota todas las dependencias que necesita la página para funcionar.

4. **config.ru**: por lo que entendí es parte del framework de Rack.  
   Básicamente sirve para decirle a las dependencias "che para run App necesito server" y que sería el archivo anterior.

5. **Rakefile**: sirve para que la gema rake pueda manejar la base de datos.

6. **config**: carpeta que tiene el archivo con la configuración de la base de datos.  
   - **database.yml**: define qué motor de base de datos se va a usar (sqlite),  
     y crea tres bases de datos diferentes:
     - Producción  
     - Desarrollo *(esta no sé por qué no se hizo, pero creo recordar que no hacía falta)*  
     - Testing  

7. **models**: carpeta con los modelos, o las clases, que tiene el programa.  
   Esto se usa para que la base de datos pueda crear cada tabla de forma más eficiente.  
   - **users.rb**: archivo con el perfil de esa clase.

8. **db**: carpeta con todos los archivos relacionados a la base de datos.  
   - **migrate**: carpeta donde se guardan las migraciones (no sé si todas o solo las propias)  
   - **schema.rb**: esto es mejor no tocarlo. Recomendable hacer todas las modificaciones que se quieran con migraciones.  
   - **test.sqlite3**: base de datos de test. Mejor usemos este siempre.  
   - **wallet_development.sqlite3**: base de datos de todo el programa. Mejor no tocarlo.

 
 
### --- Pasos para seguir para ver si funciona ---

> Aclaración: no sé si con esto se chequearía. Estos son los pasos que seguí uno por uno para chequear que se hicieron bien. Cualquier cosa a preguntar a nuestro amigo chatgpt.

## Requisitos previos
Deberías tener instalado:
* Ruby 3.2.2 (o una versión cercana)
* Bundler (gem install bundler si no lo tenés)
* SQLite3 (sudo apt install sqlite3 en Linux / usar Homebrew en macOS)


1. Correr el server (con el comando que está abajo)
    Te tendría que salir en la terminal que está corriendo, y un link. Cuando entrás, te sale la página en blanco con un msg de "Welcome to Obvio!".
2. Fijarse si rake está funcionando
    Así podes ver manejar después la base de datos. Te debería tirar una lista con todos los comandos q tiene rake. 
3. Crear una tabla con una migracion
4. Correr la migracion
5. Correr un registro desde el intérprete

## Confirmación de que todo anda
1. Te abre la web con el mensaje de bienvenida.
2. Rake te muestra tareas sin errores.
3. Se crea y migra la base sin problemas.
4. Podés usar el modelo User desde la consola.

### --- Comandos ---

Correr el server usando Rackup:
```Terminal
bundle exec rackup -p 8000
```

Fijarse si rake está funcionando:
```Terminal
bundle exec rake -T
```

Crear la Base de Datos (no hace falta porq ya está hecha)
```Terminal
exec app bundle exec rake -T
```

Crear una migración para crear una tabla
```Terminal
bundle exec rake db:create_migration NAME=create_users
```

Correr la migración
```Terminal
bundle exec rake db:migrate
```

Crear una migración para crear una tabla en la base de datos de test
```
RACK_ENV=test bundle exec rake db:create_migration NAME=create_users
```

Correr la migración
```Terminal
RACK_ENV=test bundle exec rake db:migrate
```

Entrar a la consola de ruby con la app cargada para testear modelos.
Por ejemplo:
```Terminal
bundle exec irb -I. -r server.rb
```

Crear un usario en el intérprete por consola
```
u = new User.create(name: "Doble a")
```

Comandos slite3

Este comando abre el archivo de base de datos wallet_development.sqlite3 en el cliente de SQLite. Cuando lo ejecutás,
 entrad en el entorno interactivo de SQLite, donde puedes ejecutar otros comandos
```Terminal
sqlite db/wallet_development.sqlite3
```

Este comando muestra todas las tablas que existen en la base de datos SQLite actual. 
```
.tables
```  

Este comando muestra el esquema completo de todas las tablas en la base de datos,
 es decir, las definiciones de las tablas y sus columnas.
```  
.schema
```  

nose
```  
.schema users --indent
```

### --- Gemfile ---

Explicación de cada gema:
Esta línea indica la versión de Ruby que se espera o se recomienda para este proyecto.
En este caso, es la versión 3.2.2. Aunque esta es una convención común,
```
ruby '3.2.2'
```

Esta línea es fundamental en cualquier Gemfile.
Indica el origen de donde Bundler (la herramienta que lee y procesa el Gemfile)
```
source "https://rubygems.org"
```
Declara las dependencias del proyecto (gemas requeridas).
Cada línea con `gem` especifica una gema y, opcionalmente, su versión o restricciones.

Gema: sinatra
Sinatra es un framework ligero para construir aplicaciones web en Ruby.
La restricción '~> 4.1' indica que se usará la versión 4.1.x (cualquier versión 4.1 con parches, pero no 4.2 o superior).
Esto garantiza compatibilidad con las funcionalidades esperadas sin introducir cambios mayores imprevistos.
```
gem 'sinatra', '~> 4.1'
```

Gema: rackup
`rackup` es una herramienta de línea de comandos incluida en la gema `rack`.
Se usa para iniciar servidores web compatibles con Rack, como el servidor de Sinatra.
Al incluir esta gema, aseguramos que el comando `rackup` esté disponible para ejecutar el archivo `config.ru`.
Nota: No se especifica una versión, por lo que Bundler usará la última versión estable disponible.
```
gem 'rackup'
```

Gema: puma
Puma es un servidor web concurrente y de alto rendimiento para aplicaciones Ruby/Rack.
Es comúnmente usado con Sinatra por su velocidad y capacidad para manejar múltiples solicitudes simultáneamente.
```
gem 'puma', '~> 6.6'
```

Incluye la gema sinatra-contrib, que proporciona extensiones útiles para Sinatra, como recarga automática (reloader), helpers y herramientas de desarrollo.
```
gem 'sinatra-contrib'
```

Gema: sinatra-activerecord
Integra ActiveRecord (un ORM de Ruby) con Sinatra.
Permite usar modelos y manejar bases de datos relacionales fácilmente
```
gem 'sinatra-activerecord'
```

Gema: sqlite3
Proporciona una interfaz para usar SQLite, una base de datos ligera y sin servidor.
Es ideal para desarrollo o aplicaciones pequeñas, ya que almacena datos en un solo archivo.
```
gem 'sqlite3'
```

Gema: rake
Herramienta para automatizar tareas en Ruby (similar a Make).
En este contexto, se usa para ejecutar tareas de base de datos, como migraciones con ActiveRecord (ej. `rake db:migrate`).
```
gem 'rake'
```

