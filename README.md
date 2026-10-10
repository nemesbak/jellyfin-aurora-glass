# Odin Minimal · tema para Jellyfin 12

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

## Instalación

### 1. El tema (solo CSS)

*Panel de control → General → CSS personalizado*, pega:

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-odin-minimal@main/odin-minimal.css');
```

Guarda y recarga la web con **Ctrl+F5**.

### 2. Opciones (opcional)

Añade debajo del `@import` del tema las líneas que quieras:

| Opción | Línea |
|---|---|
| Barra superior mínima (solo logo, búsqueda y usuario) | `@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-odin-minimal@main/opciones/cabecera-minima.css');` |
| Ocultar bibliotecas de la barra superior | `…/opciones/ocultar-bibliotecas-cabecera.css` |
| Ocultar «Favoritos» de la barra superior | `…/opciones/ocultar-favoritos-cabecera.css` |
| Ocultar el menú «Más» de la barra superior | `…/opciones/ocultar-menu-mas.css` |
| Título en texto en vez del logo | `…/opciones/titulo-en-texto.css` |
| Texto de tarjetas centrado | `…/opciones/tarjetas-texto-centrado.css` |
| Sin animaciones | `…/opciones/sin-animaciones.css` |
| Ocultar el carrusel | `…/opciones/sin-carrusel.css` |
| Acento coral / esmeralda / océano / rosa / oro / blanco | `…/opciones/acento-coral.css` (cambia el nombre) |

(`…` = `https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-odin-minimal@main`)

Ejemplo completo:

```css
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-odin-minimal@main/odin-minimal.css');
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-odin-minimal@main/opciones/cabecera-minima.css');
@import url('https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-odin-minimal@main/opciones/acento-coral.css');
```

También puedes cambiar el color tú mismo:

```css
:root { --om-a1: #ff6b6b; --om-a1-rgb: 255,107,107; --om-a2: #ffa94d; --om-a2-rgb: 255,169,77; }
```

### 3. Carrusel destacado y tema en el panel (opcional, requiere JavaScript)

Jellyfin no permite JavaScript desde el CSS personalizado. El carrusel de la portada (títulos recientes no vistos con logo, autoavance, «Ver ahora» reproduce directamente) y aplicar el tema también al **panel de administración** (que en la 12.x ignora el CSS personalizado) los hace `odin-home.js`.

**Docker:**

```bash
curl -fsSLO https://raw.githubusercontent.com/nemesbak/jellyfin-odin-minimal/main/install/inject-docker.sh
chmod +x inject-docker.sh
./inject-docker.sh jellyfin      # nombre de tu contenedor
```

Las actualizaciones de la imagen de Jellyfin sobrescriben la web; programa el script en cron (p. ej. cada 10 min) y se vuelve a enganchar solo:

```
*/10 * * * * /ruta/inject-docker.sh jellyfin >/dev/null 2>&1
```

**Sin Docker:** copia `odin-home.js` a la carpeta `jellyfin-web` y añade antes de `</body>` en su `index.html`:

```html
<script defer src="odin-home.js"></script>
```

Si ya usas un plugin de inyección de JavaScript (p. ej. *JavaScript Injector*), puedes pegar ahí el contenido de `odin-home.js`.

## Compatibilidad

- Probado con **Jellyfin 12.2** (web). En 10.x funciona parcialmente (la cabecera y los ajustes de la 12 usan otros componentes).
- Solo afecta a la **web** (navegador y apps que la usan, como Jellyfin Media Player). Las apps nativas (Android TV, Swiftfin, Findroid…) no cargan CSS.
- El desplegable de pistas personalizado necesita Chrome/Edge 135+; otros navegadores muestran el nativo, en oscuro.

## Desinstalar

Borra las líneas del CSS personalizado. Para el carrusel, quita la línea `<script … odin-home.js>` del `index.html` (o deja que la próxima actualización de la imagen lo haga) y elimina el cron.

## Licencia

MIT
