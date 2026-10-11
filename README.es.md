<div align="center">

# 🌌 Nebula

**Un tema oscuro, redondeado y elegante para Jellyfin 12 y Emby**

Efecto cristal · degradado violeta → cian · animaciones suaves · carrusel de portada

[English](README.md) · **Español**

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
<tr>
<td width="50%"><img src="screenshots/emby-reproductor.jpg" alt="Emby: reproductor"><br><b>Reproductor</b> con el botón central en degradado, la barra de progreso violeta→cian y controles más legibles.</td>
<td width="50%"><img src="screenshots/emby-capitulos.jpg" alt="Emby: capítulos en el reproductor"><br><b>Capítulos</b> y demás pestañas del reproductor en píldora.</td>
</tr>
</table>

**1. El tema (1 minuto):** en Emby pulsa el engranaje **⚙ (Gestionar Emby Server) → Panel de control → General**, y en **«Personalizar CSS»** pega:

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main/emby/nebula-emby.css');
```

Guarda y recarga con **Ctrl + F5**.

**2. El carrusel (opcional):** se instala con el **mismo comando** que en Jellyfin ([ver abajo](#-carrusel-destacado-opcional)). El instalador encuentra solo tu Emby (y tu Jellyfin, si tienes los dos).

> En Emby el carrusel admite los mismos ajustes `--nb-hero-*` (pégalos en «Personalizar CSS» debajo del `@import`). Las opciones de la carpeta `opciones/` son para la barra superior de Jellyfin 12 y no se aplican a Emby.

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

### ⚡ Instalación: un solo comando

Abre la **terminal del equipo donde está Jellyfin o Emby**, pega esto y pulsa Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/nebula.sh | bash
```

Recarga Jellyfin/Emby con **Ctrl + F5**. ¡Ya está! 🎉

El instalador lo hace todo solo:
- 🔍 **Encuentra** todos tus Jellyfin y Emby, estén en Docker o instalados directamente. No tienes que saber cómo se llama nada.
- 🎠 **Pone** el carrusel en cada uno.
- 🔁 **Lo vuelve a poner** solo cuando actualizas Jellyfin/Emby (las actualizaciones lo borran) y tras reiniciar el servidor.

#### 📍 ¿Dónde pego el comando?

| Tengo… | Dónde está la terminal |
|---|---|
| 🟠 **Unraid** | Arriba a la derecha, el icono **`>_`** (Terminal). Pega y listo. |
| 🟤 **Proxmox** (LXC o VM) | Pégalo **dentro** del LXC o la VM donde está Jellyfin/Emby: selecciónalo en la lista de la izquierda → **Console**. *No* en la consola del propio Proxmox. |
| 🐳 **Docker en Linux** (Ubuntu, Debian, Raspberry Pi…) | Cualquier terminal o SSH. Si pide permisos, usa `… \| sudo bash`. |
| 🔵 **Synology / QNAP** | Activa **SSH** (Synology: *Panel de control → Terminal y SNMP*), entra con PuTTY o la terminal, escribe `sudo -i` y pega. |
| 🐧 **Jellyfin/Emby instalado sin Docker** (Debian, Ubuntu, LXC de *helper-scripts*…) | La terminal de ese equipo, con `sudo` si no eres root: `curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/nebula.sh \| sudo bash` |

<details>
<summary>🐳 Uso Docker Compose o Portainer (si no sabes qué es esto, sáltalo)</summary>

**¿Qué es esto?** Es **otra forma de instalar lo mismo**. Si al montar tu Jellyfin o Emby usaste un archivo llamado `docker-compose.yml`, o lo creaste desde **Portainer**, quizá prefieras tener Nebula en ese mismo archivo, junto a lo demás. Si no te suena nada de esto, **no lo necesitas**: usa el comando de arriba.

**¿Qué hace?** Crea un contenedor pequeñito llamado `nebula` que hace de «ayudante»: busca tu Jellyfin y tu Emby, les pone el carrusel y, si una actualización lo borra, lo vuelve a poner solo.

#### 📝 Con un archivo `docker-compose.yml`

1. Abre tu archivo `docker-compose.yml` (el mismo donde tienes Jellyfin o Emby).
2. Busca la línea `services:`. Debajo verás tus programas (por ejemplo `jellyfin:`).
3. Pega esto **al final del archivo**, respetando los espacios del principio:

   ```yaml
     nebula:
       image: docker:cli
       container_name: nebula
       restart: unless-stopped
       volumes:
         - /var/run/docker.sock:/var/run/docker.sock
       entrypoint: ["sh", "-c", "apk add -q --no-cache bash curl && curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/inject-docker.sh | bash -s -- auto --watch"]
   ```

   > ⚠️ Los espacios importan: `nebula:` tiene que quedar **alineado** con `jellyfin:` (o con el nombre de tus otros programas).

4. Guarda el archivo y, en la terminal, en esa misma carpeta, escribe:
   ```bash
   docker compose up -d
   ```
5. Recarga Jellyfin/Emby con **Ctrl + F5**. ¡Listo!

#### 🧭 Con Portainer

1. Entra en Portainer → **Stacks** → **＋ Add stack**.
2. En **Name** escribe `nebula`.
3. En el cuadro grande (**Web editor**) pega esto tal cual:

   ```yaml
   services:
     nebula:
       image: docker:cli
       container_name: nebula
       restart: unless-stopped
       volumes:
         - /var/run/docker.sock:/var/run/docker.sock
       entrypoint: ["sh", "-c", "apk add -q --no-cache bash curl && curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/inject-docker.sh | bash -s -- auto --watch"]
   ```

4. Abajo del todo pulsa **Deploy the stack**.
5. Recarga Jellyfin/Emby con **Ctrl + F5**. ¡Listo!

**Para quitarlo:** en Portainer, borra el stack `nebula`. Con el archivo, borra esas líneas y escribe `docker compose up -d --remove-orphans`. Después pega el comando de [quitar el carrusel](#-quitar-el-carrusel) para limpiar Jellyfin/Emby.

<details>
<summary>🤓 Para curiosos: qué significa cada línea</summary>

- `image: docker:cli` → una imagen oficial de Docker, muy pequeña.
- `container_name: nebula` → el nombre con el que lo verás en tu lista de contenedores.
- `restart: unless-stopped` → se enciende solo cuando reinicias el servidor.
- `volumes: …docker.sock…` → le deja «ver» tus otros contenedores para poder poner el carrusel dentro de Jellyfin/Emby. Por eso no hace falta decirle cómo se llaman.
- `entrypoint: …` → al arrancar, descarga el instalador de este repositorio y se queda vigilando cada 10 minutos.

¿Quieres que ponga también el tema él solo? Añade debajo de `restart:` estas líneas, con tu clave de API (pon solo la del servidor que tengas):
```yaml
    environment:
      - JELLYFIN_API_KEY=tu_clave
      - EMBY_API_KEY=tu_clave
```
</details>
</details>

<details>
<summary>🎁 Extra: que ponga también el tema él solo</summary>

Con tu clave de API, el instalador pega también la línea del tema en «CSS personalizado» (solo si aún no está; nunca borra lo que tengas):

1. Crea una clave: Jellyfin → *Panel de control → Claves API → ＋* · Emby → *Panel de control → Claves API → Nueva*.
2. Pega el comando así, con tu clave (pon solo la del servidor que tengas):
   ```bash
   curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/nebula.sh | JELLYFIN_API_KEY=tu_clave EMBY_API_KEY=tu_clave bash
   ```
3. Opcional, solo Jellyfin: añade `NEBULA_OPTIONS=acento-coral,cabecera-minima` antes de `bash`.
</details>

<details>
<summary>🧩 Sin terminal: plugin «JavaScript Injector» (solo Jellyfin)</summary>

1. Instala un plugin de inyección de JavaScript para Jellyfin (por ejemplo **JavaScript Injector**) desde *Panel de control → Complementos → Catálogo*. Si no aparece, añade antes su repositorio siguiendo las instrucciones del propio plugin.
2. Reinicia Jellyfin.
3. En la página del plugin, crea un script nuevo y pega el contenido de [`install/cargador.js`](install/cargador.js).
4. Guarda y recarga con **Ctrl + F5**.
</details>

<details>
<summary>🛠️ A mano (avanzado)</summary>

Copia [`nebula-home.js`](nebula-home.js) (Emby: [`emby/nebula-emby-home.js`](emby/nebula-emby-home.js)) dentro de la carpeta web (Jellyfin: `jellyfin-web` · Emby: `dashboard-ui`) y añade justo antes de `</body>` en su `index.html`:

```html
<script defer src="nebula-home.js"></script>
```

> Las actualizaciones sobrescriben `index.html`: tendrás que repetirlo tras cada una (el comando de arriba lo hace solo).
</details>

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

Pega en la misma terminal donde lo instalaste:

```bash
curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/nebula.sh | bash -s -- --uninstall
```

Quita el carrusel de todos tus Jellyfin/Emby y el contenedor o la tarea que lo vigilaba. El tema (CSS) no se toca. Si lo instalaste con **Compose**, borra además el servicio `nebula` de tu archivo. Si usaste el plugin, borra allí el script.

---

<div align="center">

Hecho con 💜 para la comunidad de Jellyfin · Licencia [MIT](LICENSE)

Si te gusta, ⭐ dale una estrella al repositorio, ¡ayuda mucho!

</div>
