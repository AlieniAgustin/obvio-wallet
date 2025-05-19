## — Guía para el uso de `git` —

Este documento es una guía para los integrantes del grupo. Tiene como objetivo centralizar y explicar los comandos y conceptos esenciales del manejo de ramas en Git: su creación, cambio, actualización y fusiones. El fin es evitar errores comunes en el uso compartido del repositorio.

---

### Conceptos clave

En tu estación de trabajo, cada rama tiene tres "copias" o zonas de trabajo:

* **Working Directory**: Es donde trabajás directamente. Acá editás, agregás y eliminás archivos antes de decidir guardar algo.
* **Staging Area (o Index)**: Zona de preparación. Acá se agregan archivos para que estén listos para el próximo commit.
* **Repository (Local)**: Es donde Git guarda tus commits. Contiene el historial de versiones en tu máquina.
* **Remote Repository**: Es el repositorio remoto (en GitHub). Allí están los cambios compartidos con todo el equipo.

---

### Estructura de ramas del repositorio

Actualmente trabajamos con:

* `main`: rama principal. **No se trabaja directamente en esta rama.**
* `dev`: rama secundaria. Todo el desarrollo activo ocurre acá. Cuando una funcionalidad esté completa y revisada, se fusiona (merge) en `main`.

*Queda pendiente definir cómo y cuándo hacer los chequeos antes de mergear.*

---

### Comandos esenciales

#### Actualizar tu rama con los últimos cambios remotos

Verificar si hay nuevos cambios:

```bash
git fetch
```

Traer e incorporar los últimos cambios:

```bash
git pull
```

#### Guardar tus propios cambios

Agregar archivo individual al Staging Area:

```bash
git add <archivo>
```

Agregar todos los archivos modificados:

```bash
git add .
```

Hacer commit de los cambios agregados:

```bash
git commit -m "Descripción de los cambios"
```

Subir los commits al repositorio remoto:

```bash
git push
```

---

### Manejo de ramas

Listar ramas:

```bash
git branch
```

Crear una nueva rama:

```bash
git branch <nombre_rama>
```

Borrar una rama:

```bash
git branch -d <nombre_rama>
```

Cambiarse a una rama existente:

```bash
git checkout <nombre_rama>
```

Crear y cambiarse a una nueva rama:

```bash
git checkout -b <nombre_rama>
```

---

### Unir ramas (merge)

Cuando una funcionalidad está lista en `dev` (u otra rama), se puede integrar a `main` con un merge. Esto se hace desde la rama destino (por ejemplo, estando en `main`) y ejecutando:

```bash
git merge <rama_a_unir>
```

Git elegirá el algoritmo de merge según la situación. Si hay conflictos, deberán resolverse manualmente antes de confirmar el merge.

---

**Documentación de referencia:**

* [git\_branch.pdf](https://drive.google.com/file/d/10AZdP1cIZh9cBHJ40Y0U-XISs3SKL5Ih/view?usp=drive_open)
* [git.pdf](https://drive.google.com/file/d/1EIn2b86dE25f09kFDjz-sPtp3dE5kpPD/view)

---

*Para completar: definir el flujo de revisión antes de mergear a main (pull request, aprobación, etc).*
