<div align="center">

# 🌌 Nebula

**Un tema oscuro, redondeado y elegante para Jellyfin 12 y Emby**

Efecto cristal · degradado violeta → cian · animaciones suaves · carrusel de portada

![Jellyfin 12](https://img.shields.io/badge/Jellyfin-12.x-8b5cf6?style=for-the-badge&logo=jellyfin&logoColor=white)
![Emby 4.9+](https://img.shields.io/badge/Emby-4.9+-52b54b?style=for-the-badge&logo=emby&logoColor=white)
![Instalación](https://img.shields.io/badge/instalación-1_minuto-22d3ee?style=for-the-badge)
![Licencia MIT](https://img.shields.io/badge/licencia-MIT-555?style=for-the-badge)

![Portada con Nebula](screenshots/inicio.jpg)

</div>

---

## ✨ Antes y después

![Jellyfin normal frente a Nebula](screenshots/antes-despues.jpg)

<table>
<tr>
<td width="50%"><img src="screenshots/ficha.jpg" alt="Ficha de película"><br><b>Ficha de película</b>: el logo sustituye al título, botones redondos, pistas de audio y subtítulos como tarjetas.</td>
<td width="50%"><img src="screenshots/biblioteca.jpg" alt="Biblioteca"><br><b>Biblioteca</b>: tarjetas redondeadas, menús de cristal y filtros limpios.</td>
</tr>
<tr>
<td width="50%"><img src="screenshots/temporada.jpg" alt="Temporada"><br><b>Episodios</b> como tarjetas, con marca «✓ Visto» y sinopsis corta.</td>
<td width="50%" align="center"><img src="screenshots/movil.jpg" alt="Móvil" width="80%"><br><b>Móvil</b>: todo adaptado a pantallas pequeñas.</td>
</tr>
</table>

**Qué cambia, en resumen:**

| | |
|---|---|
| 🔘 **Todo redondeado** | Tarjetas, botones en píldora, menús y diálogos de cristal, scroll fino, fuente Inter |
| 🎬 **Ficha de película** | Logo en vez de título, entrada animada, audio y subtítulos con desplegable propio, reparto en círculos |
| 📺 **Episodios** | Tarjetas con «play» al pasar el ratón y marca de visto |
| ▶️ **Reproductor** | Botón de pausa con degradado, barra de progreso que brilla, «saltar intro» de cristal |
| 🔐 **Resto** | Login, búsqueda, guía de TV, favoritos y panel de administración a juego |
| 📱 **Móvil** | Adaptado a pantallas estrechas |

---

## 🚀 Instalación del tema (1 minuto, sin instalar nada)

> Solo hace falta copiar y pegar **una línea**. No tocas archivos, no reinicias nada, y si no te gusta lo quitas igual de fácil.

**1.** Entra en Jellyfin con una cuenta de **administrador**. Pulsa tu **foto de usuario** (arriba a la derecha) → **Panel de control**.

**2.** En el menú de la izquierda, abre **Personalización de apariencia**.

**3.** En el cuadro **«Código CSS personalizado»**, pega esta línea:

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/nebula.css');
```

**4.** Pulsa **Guardar** abajo del todo.

**5.** Recarga la página con **Ctrl + F5** (en Mac: **Cmd + Shift + R**). En el móvil, cierra la app o la pestaña y ábrela otra vez.

¡Listo! 🎉 Se aplica a **todos los usuarios** y se actualiza solo cuando mejoro el tema.

> 💡 ¿Quieres además el **carrusel grande de la portada** (la imagen de arriba)? Está al final: [🎠 Carrusel destacado](#-carrusel-destacado-opcional).

---

## 🎨 Opciones

Cada opción es **una línea más** que pegas **debajo** de la del tema, en el mismo cuadro de «Código CSS personalizado» (*Panel de control → Personalización de apariencia*). Puedes combinar todas las que quieras.

### 🌈 Color de acento

Cambia el violeta → cian por otro color. Pon **solo una** de estas líneas:

![Colores de acento](screenshots/opcion-acentos.png)

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/acento-coral.css');
```

Cambia `acento-coral` por el que quieras: `acento-coral` · `acento-esmeralda` · `acento-oceano` · `acento-rosa` · `acento-oro` · `acento-blanco`.

<details>
<summary>🎛️ ¿Quieres tu propio color exacto?</summary>

Pega esto debajo del tema y cambia los colores (cada uno en formato `#hex` y en números `R,G,B`):

```css
:root {
  --nb-a1: #ff6b6b; --nb-a1-rgb: 255,107,107;   /* color 1 */
  --nb-a2: #ffa94d; --nb-a2-rgb: 255,169,77;    /* color 2 */
  --nb-on-accent: #fff;                          /* texto sobre el botón (pon #111 si tus colores son claros) */
}
```
</details>

### 🧭 Barra superior

Jellyfin 12 pone las bibliotecas arriba. Si prefieres una barra más limpia:

![Opciones de la barra superior](screenshots/opcion-cabecera.png)

| Quiero… | Pega esta línea |
|---|---|
| Barra **mínima** (solo logo, búsqueda y usuario) | `@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/cabecera-minima.css');` |
| Quitar solo las **bibliotecas** | `@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/ocultar-bibliotecas-cabecera.css');` |
| Quitar solo **Favoritos** | `@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/ocultar-favoritos-cabecera.css');` |
| Quitar solo el menú **«Más»** | `@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/ocultar-menu-mas.css');` |

> No pierdes nada: las bibliotecas siguen en «Mis contenidos» de la portada y en el menú ☰.

### 🏷️ Título en texto en vez del logo

Por defecto la ficha muestra el **logo** de la película. Si prefieres el nombre escrito:

![Logo o título en texto](screenshots/opcion-titulo.jpg)

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/titulo-en-texto.css');
```

### 🃏 Texto de las tarjetas centrado

Nebula alinea el título y el año a la izquierda. Para centrarlos como en Jellyfin normal:

![Texto de tarjetas](screenshots/opcion-tarjetas.jpg)

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/tarjetas-texto-centrado.css');
```

### 🐢 Sin animaciones

Para equipos lentos, televisores o si simplemente no te gustan los efectos. Todo aparece al instante:

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/sin-animaciones.css');
```

### 📋 Ejemplo completo

Así quedaría el cuadro con el tema + color coral + barra mínima:

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/nebula.css');
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/acento-coral.css');
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/cabecera-minima.css');
```

> ⚠️ Las líneas `@import` tienen que ir **al principio** del cuadro, antes de cualquier otro CSS que tengas.

---

## 📺 Nebula para Emby

¿Usas **Emby**? Nebula también está para Emby 4.9 / 4.10, con la misma estética y el mismo carrusel.

<table>
<tr>
<td width="50%"><img src="screenshots/emby-inicio.jpg" alt="Emby: portada con carrusel"><br><b>Portada</b> con el carrusel destacado y pestañas en píldora.</td>
<td width="50%"><img src="screenshots/emby-ficha.jpg" alt="Emby: ficha"><br><b>Ficha</b> con botones de cristal, pistas en píldora y reparto en círculos.</td>
</tr>
</table>

**1. El tema (1 minuto):** en Emby pulsa el engranaje **⚙ (Gestionar Emby Server) → Panel de control → General**, y en **«Personalizar CSS»** pega:

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/emby/nebula-emby.css');
```

Guarda y recarga con **Ctrl + F5**.

**2. El carrusel (opcional):** exactamente igual que en Jellyfin ([ver abajo](#-carrusel-destacado-opcional)), solo cambia el nombre del contenedor por el de Emby. El instalador detecta solo si es Jellyfin o Emby:

```bash
docker run -d --name nebula-emby --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -e JELLYFIN_CONTAINER=emby docker:cli sh -c 'apk add -q --no-cache bash curl && curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/inject-docker.sh | bash -s -- "$JELLYFIN_CONTAINER" --watch'
```

> En Emby el carrusel admite los mismos ajustes `--nb-hero-*` (pégalos en «Personalizar CSS» debajo del `@import`). Las opciones de la carpeta `opciones/` son para la barra superior de Jellyfin 12 y no se aplican a Emby.
> Si tienes **Jellyfin y Emby en el mismo servidor**, puedes tener los dos contenedores (`nebula` y `nebula-emby`) a la vez.

---

## ❓ Preguntas frecuentes

<details>
<summary><b>He pegado la línea y no cambia nada</b></summary>

1. Asegúrate de haber pulsado **Guardar**.
2. Recarga con **Ctrl + F5** (el navegador guarda la versión vieja).
3. Comprueba que la línea está **la primera** del cuadro y sin espacios raros delante.
</details>

<details>
<summary><b>¿Funciona en la app de mi tele / móvil?</b></summary>

Funciona en todo lo que usa la **web** de Jellyfin: el navegador (PC y móvil), la app **Jellyfin Media Player** y la app oficial de **Android** (que por dentro es la web). Las apps «nativas» como **Android TV, Swiftfin (iPhone/Apple TV) o Findroid** no cargan CSS, así que ahí no se ve.
</details>

<details>
<summary><b>¿Tengo que actualizar algo cuando saque mejoras?</b></summary>

No. La línea siempre apunta a la última versión. Puede tardar unas horas en llegarte por la caché; un **Ctrl + F5** ayuda.
</details>

<details>
<summary><b>¿Funciona con Jellyfin 10.x?</b></summary>

Está hecho para **Jellyfin 12**. En 10.x funciona a medias (la barra superior y los ajustes de la 12 son distintos).
</details>

<details>
<summary><b>¿Cómo lo quito?</b></summary>

Borra las líneas del cuadro «Código CSS personalizado» (*Panel de control → Personalización de apariencia*), guarda y recarga. Jellyfin vuelve a ser como antes. (Si instalaste el carrusel, mira [cómo quitarlo](#-quitar-el-carrusel).)
</details>

---

## 🎠 Carrusel destacado (opcional)

El carrusel es la **imagen grande de la portada** que va pasando sola: títulos recientes que aún no has visto, con su logo, año, nota, géneros, sinopsis y dos botones: **Ver ahora** (empieza a reproducir) y **Más info**. Se pausa al pasar el ratón y en el móvil se desliza con el dedo.

![Con y sin carrusel](screenshots/opcion-carrusel.jpg)

> 🤔 **¿Por qué es aparte?** Jellyfin solo deja poner CSS (colores y formas). El carrusel es un pequeño programa (JavaScript), y para añadirlo hay que darle permiso a Jellyfin una vez. De paso, también aplica el tema al **panel de administración**, que en Jellyfin 12 ignora el CSS personalizado.

Elige **una** de estas formas, de la más fácil a la más manual:

### 🥇 Opción A — Una línea en Docker (recomendada)

Si tu Jellyfin (o Emby) está en **Docker** (Unraid, Synology, Portainer, un servidor Linux…), abre la **terminal** de ese equipo y pega:

```bash
docker run -d --name nebula --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -e JELLYFIN_CONTAINER=jellyfin docker:cli sh -c 'apk add -q --no-cache bash curl && curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/inject-docker.sh | bash -s -- "$JELLYFIN_CONTAINER" --watch'
```

Recarga Jellyfin con **Ctrl + F5** y ya tienes el carrusel. Esto crea un contenedor pequeñito llamado `nebula` que:
- ✅ instala el carrusel en tu Jellyfin,
- ✅ lo **vuelve a poner solo** cada vez que actualices Jellyfin (las actualizaciones lo borran),
- ✅ sobrevive a los reinicios del servidor.

<details>
<summary>📍 ¿Dónde está la terminal? ¿Cómo se llama mi contenedor?</summary>

- **Unraid**: arriba a la derecha, el icono **`>_`** (Terminal).
- **Synology**: activa SSH en *Panel de control → Terminal y SNMP* y conéctate con PuTTY, o usa *Container Manager*.
- **Portainer**: mejor usa la opción B (Compose) creando un *Stack*.
- **Linux**: cualquier terminal (si da error de permisos, pon `sudo` delante).

**Nombre del contenedor:** la línea supone que se llama `jellyfin`. Para comprobarlo, escribe `docker ps` y busca el de Jellyfin en la última columna (*NAMES*). Si se llama distinto (por ejemplo `Jellyfin` o `jellyfin-server`), cambia `JELLYFIN_CONTAINER=jellyfin` por ese nombre.
</details>

<details>
<summary>🎁 Extra: que ponga también el tema él solo</summary>

Si añades tu clave de API, el contenedor también pega la línea del tema en «CSS personalizado» por ti (solo si aún no está; nunca borra lo que tengas):

1. En Jellyfin: **Panel de control → Claves API → ＋**, ponle un nombre (`nebula`) y copia la clave.
2. Añade `-e JELLYFIN_API_KEY=tu_clave` a la línea de arriba, justo después de `-e JELLYFIN_CONTAINER=jellyfin`.
3. Opcional: `-e NEBULA_OPTIONS=acento-coral,cabecera-minima` para añadir opciones.
</details>

### 🥈 Opción B — Docker Compose

Si usas un archivo `docker-compose.yml` (o *Stacks* de Portainer), añade este servicio junto al de Jellyfin y ejecuta `docker compose up -d`:

```yaml
  nebula:
    image: docker:cli
    container_name: nebula
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JELLYFIN_CONTAINER=jellyfin   # nombre de tu contenedor de Jellyfin
      - JELLYFIN_API_KEY=             # opcional: también pone el tema en «CSS personalizado»
      - NEBULA_OPTIONS=               # opcional: p. ej. acento-coral,cabecera-minima
    entrypoint: ["sh", "-c", "apk add -q --no-cache bash curl && curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/inject-docker.sh | bash -s -- \"$$JELLYFIN_CONTAINER\" --watch"]
```

(También lo tienes listo en [`install/docker-compose.yml`](install/docker-compose.yml).)

### 🥉 Opción C — Plugin «JavaScript Injector» (sin terminal)

Si no usas Docker o no quieres tocar la terminal:

1. Instala un plugin de inyección de JavaScript para Jellyfin (por ejemplo **JavaScript Injector**) desde *Panel de control → Complementos → Catálogo*. Si no aparece, añade antes su repositorio siguiendo las instrucciones del propio plugin.
2. Reinicia Jellyfin.
3. En la página del plugin, crea un script nuevo y pega el contenido de [`install/cargador.js`](install/cargador.js).
4. Guarda y recarga con **Ctrl + F5**.

### 🛠️ Opción D — A mano (avanzado)

Copia [`nebula-home.js`](nebula-home.js) dentro de la carpeta `jellyfin-web` de tu instalación y añade esta línea justo antes de `</body>` en su `index.html`:

```html
<script defer src="nebula-home.js"></script>
```

> Las actualizaciones de Jellyfin sobrescriben `index.html`: tendrás que repetirlo tras cada actualización (por eso la opción A lo hace sola).

### 🎛️ Personalizar el carrusel

Se ajusta desde el **mismo cuadro de «Código CSS personalizado»**, debajo de las líneas del tema. Pon solo lo que quieras cambiar:

| Ajuste | Qué hace | Por defecto |
|---|---|---|
| `--nb-hero-count` | Cuántos títulos salen (`0` = sin carrusel) | `8` |
| `--nb-hero-interval` | Segundos por diapositiva (`0` = no avanza solo) | `8` |
| `--nb-hero-source` | De dónde salen: `recent` (recientes) · `toprated` (mejor valorados) · `random` (al azar) · `favorites` (favoritos de cada usuario) | `recent` |
| `--nb-hero-types` | `"Movie"` (pelis), `"Series"` o ambos | `"Movie,Series"` |
| `--nb-hero-library` | Solo de estas bibliotecas, por su nombre: `"Películas"` o `"Películas,Anime"` | todas |
| `--nb-hero-days` | Con `recent`: añadidos en los últimos N días (`0` = sin límite) | `120` |
| `--nb-hero-unwatched` | `1` = solo lo que aún no has visto | `1` |
| `--nb-hero-logo` | `1` = solo títulos con logo · `0` = también sin logo (escribe el nombre) | `1` |
| `--nb-hero-overview` / `-genres` / `-rating` | Mostrar sinopsis / géneros / nota (`1` sí, `0` no) | `1` |
| `--nb-hero-buttons` | Botones «Ver ahora» y «Más info» | `1` |
| `--nb-hero-play` | `1` = «Ver ahora» reproduce · `0` = solo abre la ficha | `1` |
| `--nb-hero-height` | Alto en ordenador | `min(68vh, 640px)` |
| `--nb-hero-height-mobile` | Alto en móvil | `62vh` |

**Ejemplos** (copia el que te guste):

```css
/* Las 10 mejor valoradas de la biblioteca «Películas», cambiando cada 12 segundos */
:root { --nb-hero-count: 10; --nb-hero-source: toprated; --nb-hero-library: "Películas"; --nb-hero-interval: 12; }
```

```css
/* Solo series al azar, sin sinopsis y más bajito */
:root { --nb-hero-types: "Series"; --nb-hero-source: random; --nb-hero-overview: 0; --nb-hero-height: 50vh; }
```

```css
/* Los favoritos de cada usuario (aunque ya los haya visto) */
:root { --nb-hero-source: favorites; --nb-hero-unwatched: 0; }
```

> ¿Solo quieres esconder el carrusel un tiempo, sin desinstalarlo? Pega `@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/opciones/sin-carrusel.css');`

### 🧹 Quitar el carrusel

- **Opción A o B (Docker):** borra el contenedor y limpia Jellyfin con estas dos líneas:
  ```bash
  docker rm -f nebula
  curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/inject-docker.sh | bash -s -- jellyfin --uninstall
  ```
- **Opción C:** borra el script en la página del plugin.
- **Opción D:** quita la línea `<script … nebula-home.js>` de `index.html` (o espera a la próxima actualización de Jellyfin, que la borra).

---

<div align="center">

Hecho con 💜 para la comunidad de Jellyfin · Licencia [MIT](LICENSE)

Si te gusta, ⭐ dale una estrella al repositorio, ¡ayuda mucho!

</div>
