
## --- Guía para el uso de `Docker` en el proyecto ---

Este documento sirve como guía para todos los integrantes del grupo. El objetivo es entender cómo usar Docker correctamente en el proyecto, evitar errores por mal uso y tener todos los comandos a mano.

---

### 🧠 Conceptos clave

- **Imagen**: una plantilla inmutable que contiene todo lo necesario para ejecutar una aplicación (por ejemplo: Ruby + dependencias + tu código).

- **Contenedor (Container)**: es una instancia en ejecución de una imagen. Es como una “máquina virtual liviana”, que aísla tu aplicación y sus dependencias del resto del sistema.

- **Dockerfile**: es el archivo que define cómo se construye una imagen. Cada instrucción del Dockerfile agrega una “capa” a la imagen.

---

### ⚙️ Comandos útiles

#### 🛠 Construir la imagen

Este paso solo se hace la primera vez o cuando se cambia el `Dockerfile`, el `Gemfile`, o algo importante que afecte el entorno.

```bash
docker build -t sinatra-obvio .
```

- `-t sinatra-obvio`: le pone el nombre (tag) `sinatra-obvio` a la imagen.

---

#### 🚀 Correr la aplicación con Docker directamente

```bash
docker run -d --name app -p 8000:8000 sinatra-obvio
```

- `-d`: corre el contenedor en segundo plano (detached).
- `--name app`: nombra al contenedor `app`.
- `-p 8000:8000`: mapea el puerto 8000 del contenedor al puerto 8000 de tu máquina.
- `sinatra-obvio`: es el nombre de la imagen que construiste antes.

---

#### 💡 ¿Y si no tengo Ruby instalado?

Si tenés Windows o no tenés Ruby compatible en tu sistema, podés usar Docker para ejecutar cualquier comando Ruby (como `bundle`, `rake`, etc.) **dentro del contenedor**.

---

### 🧩 Usando Docker Compose

Si tenés el archivo `docker-compose.yml`, podés levantar todo con un solo comando. Ideal para desarrollo continuo sin reiniciar a cada rato.

```bash
docker compose up -d --build
```

Esto:
- Construye la imagen (si hace falta).
- Levanta el contenedor en segundo plano.

Para chequear que está corriendo podes aplicar

```bash
docker ps
```

Deberías ver un mensaje como este (con los datos de cómo configuraste tu imagen y contenedor):

```bash
CONTAINER ID   IMAGE               COMMAND                  CREATED         STATUS         PORTS                    NAMES
bd965953ab69   sinatra-obvio-app   "bundle exec rackup …"   5 seconds ago   Up 4 seconds   0.0.0.0:8000->8000/tcp   sinatra-obvio-app-1
```


---

#### 📦 Instalar las dependencias de Ruby (gems)

Una vez levantado el contenedor, cualquier comando que quieras ejecutar dentro de él se hace así:

```bash
docker compose exec app bundle
```

Deberías ver un mensaje como:

```bash
Bundle complete! 7 Gemfile dependencies, 29 gems now installed.
Bundled gems are installed into `/usr/local/bundle`
```

---

### 📚 Referencias

Estas notas están basadas en las presentaciones vistas en la materia.

[Docker.pdf](https://drive.google.com/file/d/1DasgR8ulZIiUBzaMdzcHW0hIhM6AiNyr/view)
