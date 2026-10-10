# Aurora Glass · tema para Jellyfin 12

Tema oscuro, minimalista y redondeado para la web de **Jellyfin 12.x**, con acento en degradado violeta → cian, efectos de cristal y animaciones suaves. Incluye un **carrusel destacado** opcional para la portada.

![Portada con carrusel](screenshots/inicio.jpg)
![Temporada con episodios](screenshots/temporada.jpg)

## Qué cambia

- **Todo redondeado**: tarjetas, botones en píldora, menús y diálogos de cristal, scrollbar fina, fuente Inter.
- **Tarjetas**: título y año alineados a la izquierda; al pasar el ratón se elevan con halo de color, reflejo diagonal y play con degradado.
- **Ficha de película/serie**: el **logo de la película sustituye al título** (si existe); animación de entrada (fondo con zoom, póster, botones uno a uno); vídeo/audio/subtítulos como tarjetas con icono y **desplegable personalizado** (Chrome/Edge 135+); créditos en tabla; etiquetas al final; reparto en círculos.
- **Episodios** como tarjetas con play al pasar, sinopsis de 2 líneas y marca «✓ Visto».
- **Reproductor**: play/pausa con degradado, barra de progreso con brillo que se ensancha, botones de saltar intro y «siguiente episodio» de cristal.
- **Login** de cristal, **búsqueda** grande, **guía de TV** con celdas redondeadas, **favoritos vacíos** con aviso, **panel de administración** a juego.
- **Móvil / pantallas estrechas** adaptado.

## Instalación rápida (Docker) — todo en una línea

Instala **tema + carrusel**, y los vuelve a poner solos cada vez que se actualiza Jellyfin. Necesitas una clave de API (*Panel de control → Claves de API → +*). Cambia `jellyfin` si tu contenedor se llama de otra forma.

**Docker Compose:** añade este servicio a tu `docker-compose.yml` (o copia [`install/docker-compose.yml`](install/docker-compose.yml)) y haz `docker compose up -d`:

```yaml
  aurora-glass:
    image: docker:cli
    container_name: aurora-glass
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JELLYFIN_CONTAINER=jellyfin
      - JELLYFIN_API_KEY=tu_clave_de_api
      - AURORA_OPTIONS=               # opcional: cabecera-minima,acento-coral…
    entrypoint: ["sh", "-c", "apk add -q --no-cache bash curl && curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-aurora-glass/main/install/inject-docker.sh | bash -s -- \"$$JELLYFIN_CONTAINER\" --watch"]
```

**Docker (una línea):**

```bash
docker run -d --name aurora-glass --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -e JELLYFIN_CONTAINER=jellyfin -e JELLYFIN_API_KEY=tu_clave_de_api docker:cli sh -c 'apk add -q --no-cache bash curl && curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-aurora-glass/main/install/inject-docker.sh | bash -s -- "$JELLYFIN_CONTAINER" --watch'
```

Funciona igual en **Unraid**: pégala en la terminal (sobrevive a reinicios gracias a `--restart unless-stopped`).

Recarga la web con **Ctrl+F5** y listo. Notas:
- El tema solo se escribe en *CSS personalizado* si **aún no tiene** Aurora Glass; si ya tenías CSS propio, se conserva debajo. A partir de ahí lo editas tú a mano (opciones, colores, carrusel…) y nunca se sobrescribe.
- Sin `JELLYFIN_API_KEY` instala solo el carrusel; el tema lo pegas tú (paso 1 de abajo).
- Desinstalar: `docker rm -f aurora-glass` y luego la línea de [Desinstalar](#desinstalar).

## Instalación manual

### 1. El tema (solo CSS)

*Panel de control → General → CSS personalizado*, pega:

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-aurora-glass@main/aurora-glass.css');
```

Guarda y recarga la web con **Ctrl+F5**.

### 2. Opciones (opcional)

Añade debajo del `@import` del tema las líneas que quieras:

| Opción | Línea |
|---|---|
| Barra superior mínima (solo logo, búsqueda y usuario) | `@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-aurora-glass@main/opciones/cabecera-minima.css');` |
| Ocultar bibliotecas de la barra superior | `…/opciones/ocultar-bibliotecas-cabecera.css` |
| Ocultar «Favoritos» de la barra superior | `…/opciones/ocultar-favoritos-cabecera.css` |
| Ocultar el menú «Más» de la barra superior | `…/opciones/ocultar-menu-mas.css` |
| Título en texto en vez del logo | `…/opciones/titulo-en-texto.css` |
| Texto de tarjetas centrado | `…/opciones/tarjetas-texto-centrado.css` |
| Sin animaciones | `…/opciones/sin-animaciones.css` |
| Ocultar el carrusel | `…/opciones/sin-carrusel.css` |
| Acento coral / esmeralda / océano / rosa / oro / blanco | `…/opciones/acento-coral.css` (cambia el nombre) |

(`…` = `https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-aurora-glass@main`)

Ejemplo completo:

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-aurora-glass@main/aurora-glass.css');
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-aurora-glass@main/opciones/cabecera-minima.css');
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-aurora-glass@main/opciones/acento-coral.css');
```

También puedes cambiar el color tú mismo:

```css
:root { --ag-a1: #ff6b6b; --ag-a1-rgb: 255,107,107; --ag-a2: #ffa94d; --ag-a2-rgb: 255,169,77; }
```

### 3. Carrusel destacado (opcional)

Carrusel a pantalla completa en la portada: fondo, logo de la película/serie, año, duración, nota, géneros, sinopsis y botones «Ver ahora» (reproduce directamente) y «Más info». Avanza solo, se pausa al pasar el ratón y en el móvil se desliza con el dedo. De paso aplica el tema también al **panel de administración** (la 12.x ignora ahí el CSS personalizado).

Jellyfin no deja meter JavaScript desde el CSS personalizado, así que elige **una** de estas formas:

**A) Docker — una línea** (si no usas la [instalación rápida](#instalación-rápida-docker--todo-en-una-línea); en el servidor, cambia `jellyfin` por el nombre de tu contenedor):

```bash
curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-aurora-glass/main/install/inject-docker.sh | bash -s -- jellyfin --cron
```

Lo instala y, con `--cron`, lo vuelve a enganchar cada 10 min (las actualizaciones de la imagen de Jellyfin borran la web). Sin `--cron` solo lo instala una vez.
En **Unraid** el crontab se borra al reiniciar: pon la misma línea en *User Scripts* («At Startup of Array») o en `/boot/config/go`.

**B) Plugin *JavaScript Injector*** (sin tocar el servidor): instala el plugin desde el catálogo, crea un script nuevo y pega el contenido de [`install/cargador.js`](install/cargador.js). Carga siempre la última versión.

**C) A mano:** copia `aurora-home.js` a la carpeta `jellyfin-web` y añade antes de `</body>` en su `index.html`:

```html
<script defer src="aurora-home.js"></script>
```

#### Personalizar el carrusel

Todo se ajusta desde el mismo **CSS personalizado**, debajo del `@import` del tema. Pon solo lo que quieras cambiar:

```css
:root {
  --ag-hero-count: 8;              /* nº de títulos (0 = sin carrusel) */
  --ag-hero-interval: 8;           /* segundos por diapositiva (0 = no avanza solo) */
  --ag-hero-source: recent;        /* recent · toprated · random · favorites */
  --ag-hero-types: "Movie,Series"; /* "Movie", "Series" o ambos */
  --ag-hero-library: "";           /* biblioteca(s) por nombre: "Películas" o "Películas,Anime"; vacío = todas */
  --ag-hero-days: 120;             /* con recent: añadidos en los últimos N días (0 = sin límite) */
  --ag-hero-unwatched: 1;          /* 1 = solo no vistos */
  --ag-hero-logo: 1;               /* 1 = solo títulos con logo · 0 = también sin logo (muestra el nombre) */
  --ag-hero-overview: 1;           /* sinopsis */
  --ag-hero-genres: 1;             /* géneros */
  --ag-hero-rating: 1;             /* nota ★ */
  --ag-hero-buttons: 1;            /* botones «Ver ahora» / «Más info» */
  --ag-hero-play: 1;               /* 1 = «Ver ahora» reproduce; 0 = solo abre la ficha */
  --ag-hero-height: min(68vh, 640px);  /* alto en ordenador */
  --ag-hero-height-mobile: 62vh;       /* alto en móvil */
}
```

Ejemplos:

```css
/* Las 10 mejor valoradas de la biblioteca «Películas», cambiando cada 12 s */
:root { --ag-hero-count: 10; --ag-hero-source: toprated; --ag-hero-library: "Películas"; --ag-hero-interval: 12; }

/* Solo series al azar, sin sinopsis y más bajo */
:root { --ag-hero-types: "Series"; --ag-hero-source: random; --ag-hero-overview: 0; --ag-hero-height: 50vh; }

/* Los favoritos de cada usuario */
:root { --ag-hero-source: favorites; --ag-hero-unwatched: 0; }
```

Guarda y recarga con **Ctrl+F5**. Los colores del carrusel siguen al acento del tema (opciones `acento-*.css`).

## Compatibilidad

- Probado con **Jellyfin 12.2** (web). En 10.x funciona parcialmente (la cabecera y los ajustes de la 12 usan otros componentes).
- Solo afecta a la **web** (navegador y apps que la usan, como Jellyfin Media Player). Las apps nativas (Android TV, Swiftfin, Findroid…) no cargan CSS.
- El desplegable de pistas personalizado necesita Chrome/Edge 135+; otros navegadores muestran el nativo, en oscuro.

## Desinstalar

Borra las líneas del CSS personalizado. Carrusel en Docker:

```bash
curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-aurora-glass/main/install/inject-docker.sh | bash -s -- jellyfin --uninstall
```

Con *JavaScript Injector*, borra el script del plugin.

## Licencia

MIT
