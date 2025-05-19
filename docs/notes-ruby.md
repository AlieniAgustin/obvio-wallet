## --- Guía para entender cómo funciona `sinatra-obvio` ---

Este markdown es una guía para los integrantes del grupo, así podemos entender y tener a mano todos los archivos relacionados al lenguaje Ruby a tener en cuenta a la hora del desarrollo de la aplicación `Obvio`.  

### Estructura del proyecto

1. **Gemfile**
   Lista todas las **gemas** (librerías) que necesita el proyecto para funcionar.
   Cuando corrés `bundle install`, se usa este archivo para instalar esas gemas.

2. **Gemfile.lock**
   Es la "foto" exacta de las gemas instaladas (con sus versiones específicas).
   Si todos usamos Ubuntu, no hay que modificarlo.
   Si alguien usa otro sistema operativo, puede borrarlo y volver a correr `bundle install` para generar uno compatible.

3. **server.rb**
   Es como el "punto de entrada" del proyecto.
   Acá se configura la aplicación y se define qué muestra cuando alguien entra al sitio. También se cargan las dependencias necesarias.

4. **config.ru**
   Archivo usado por Rack (el sistema que corre la app).
   Le dice a Rack cuál es el archivo principal de la app (en este caso, `server.rb`).

5. **Rakefile**
   Permite usar comandos automáticos con `rake`, especialmente para trabajar con la base de datos.

6. **config/**
   Carpeta con archivos de configuración.

   * **database.yml**: define el tipo de base de datos (en este caso, SQLite) y las bases para cada entorno:

     * Producción *(no está creada, pero podría no ser necesaria)*
     * Desarrollo 
     * Testing

7. **models/**
   Contiene los **modelos** (clases que representan tablas en la base de datos).

   * **users.rb**: define la clase `User`, que se convierte en una tabla.

8. **db/**
   Carpeta con todo lo relacionado a la base de datos.

   * **migrate/**: guarda las migraciones (scripts para crear/modificar tablas).
   * **schema.rb**: representa el estado actual de la base. No debería editarse a mano.
   * **test.sqlite3**: base de datos usada para hacer pruebas.
   * **wallet\_development.sqlite3**: base de datos principal. Mejor no tocarla directamente.

---

## --- Pasos para comprobar que todo funciona ---

> Nota: Estos son los pasos que usé para verificar que la app esté bien armada. Si algo no funciona, podés preguntar a nuestro amigo ChatGPT.

### Requisitos previos

Debés tener instalado:

* Ruby 3.2.3 (o una versión cercana)
* Bundler (`gem install bundler` si no lo tenés)
* SQLite3 (`sudo apt install sqlite3` en Linux o usar Homebrew en macOS)

### Pasos

1. **Correr el servidor**
   Te va a mostrar en consola que está corriendo y un link para abrir la página. Debería aparecer un mensaje tipo "Welcome to Obvio!".

2. **Ver si `rake` está funcionando**
   Esto permite manejar tareas de base de datos. Debería mostrarte una lista de comandos disponibles.

3. **Crear una migración para una tabla**

4. **Ejecutar la migración**

5. **Probar la creación de un registro desde la consola**

### Confirmación de que anda todo bien

1. Se abre la web con el mensaje de bienvenida.
2. `rake` responde con la lista de tareas.
3. Se crea y migra la base sin errores.
4. Podés usar el modelo `User` en la consola.

---

## --- Comandos útiles ---

**Levantar el servidor**

```bash
bundle exec rackup -p 8000
```

**Ver tareas de `rake` disponibles**

```bash
bundle exec rake -T
```

**(Opcional) Crear base de datos**
(No hace falta si ya está creada)

```bash
bundle exec rake db:create
```

**Crear una migración**

```bash
bundle exec rake db:create_migration NAME=create_users
```

**Ejecutar migración**

```bash
bundle exec rake db:migrate
```

**Migraciones para entorno de prueba**

```bash
RACK_ENV=test bundle exec rake db:create_migration NAME=create_users
RACK_ENV=test bundle exec rake db:migrate
```

**Entrar a la consola de Ruby con la app cargada**

```bash
bundle exec irb -I. -r server.rb
```

**Crear un usuario desde la consola**

```ruby
u = User.create(name: "Doble a")
```

---

## --- Comandos de SQLite3 ---

**Abrir base de datos**

```bash
sqlite3 db/wallet_development.sqlite3
```

**Ver tablas existentes**

```sql
.tables
```

**Ver estructura de todas las tablas**

```sql
.schema
```

**Ver estructura de la tabla `users` con formato indentado**

```sql
.schema users --indent
```

---

## --- Explicación del `Gemfile` ---

**ruby '3.2.2'**
Indica la versión recomendada de Ruby para este proyecto.

**source "[https://rubygems.org](https://rubygems.org)"**
Es el sitio desde donde se descargan las gemas.

**gem 'sinatra', '\~> 4.1'**
Framework web simple y liviano para Ruby. Esta versión garantiza compatibilidad con parches de la serie 4.1.

**gem 'rackup'**
Herramienta para levantar servidores Rack. Permite ejecutar `config.ru`.

**gem 'puma', '\~> 6.6'**
Servidor web rápido y concurrente para apps Ruby.

**gem 'sinatra-contrib'**
Agrega funcionalidades extras a Sinatra como recarga automática y helpers.

**gem 'sinatra-activerecord'**
Conecta Sinatra con ActiveRecord (el sistema ORM que maneja la base de datos).

**gem 'sqlite3'**
Gema que permite usar SQLite desde Ruby.

**gem 'rake'**
Herramienta de automatización de tareas. Se usa para correr tareas como las migraciones de la base.


Estas notas están basadas en las presentaciones hechas en la materia.
(Ruby.pdf)[https://drive.google.com/file/d/1Fur4MoUkoSe_q7EIcfuyf8rhW6iPCzBi/view]