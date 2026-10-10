#!/bin/bash
# Aurora Glass — instala/actualiza el carrusel (aurora-home.js) en un Jellyfin en Docker.
# Idempotente: si una actualización de la imagen borra el script, basta con volver a ejecutarlo.
#
# Instalación en una línea:
#   curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-aurora-glass/main/install/inject-docker.sh | bash -s -- jellyfin --cron
#
# Uso:  inject-docker.sh [nombre_contenedor] [--cron | --uninstall]     (por defecto: jellyfin)
#   --cron       además lo programa cada 10 min (se reengancha solo tras actualizar Jellyfin)
#   --uninstall  quita el script del index.html y el cron
# Variables opcionales:
#   JS_URL   URL de aurora-home.js   (por defecto: la última versión del repo en jsDelivr)
#   WEB      carpeta web dentro del contenedor (por defecto: /jellyfin/jellyfin-web)
set -u
C="${1:-jellyfin}"; MODO="${2:-}"
WEB="${WEB:-/jellyfin/jellyfin-web}"
REPO="https://raw.githubusercontent.com/nemesbak/jellyfin-aurora-glass/main"
JS_URL="${JS_URL:-https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-aurora-glass@main/aurora-home.js}"
DIR="${AURORA_DIR:-$HOME/.aurora-glass}"
TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT

docker inspect -f '{{.State.Running}}' "$C" 2>/dev/null | grep -q true || { echo "Contenedor '$C' no está en marcha"; exit 0; }

if [ "$MODO" = "--uninstall" ]; then
  docker exec "$C" sed -i 's#<script defer src="aurora-home.js?v=[^"]*"></script>##' "$WEB/index.html"
  docker exec "$C" rm -f "$WEB/aurora-home.js"
  crontab -l 2>/dev/null | grep -v "aurora-glass" | crontab - 2>/dev/null
  echo "Carrusel desinstalado (recarga la web con Ctrl+F5)"; exit 0
fi

curl -fsSL "$JS_URL" -o "$TMP" || { echo "No se pudo descargar $JS_URL"; exit 1; }

L=$(md5sum < "$TMP" | cut -c1-32)
R=$(docker exec "$C" md5sum "$WEB/aurora-home.js" 2>/dev/null | cut -c1-32)
if [ "$L" != "$R" ]; then
  docker cp "$TMP" "$C:$WEB/aurora-home.js" && echo "aurora-home.js copiado"
fi

V=${L:0:8}
if ! docker exec "$C" grep -q "aurora-home.js?v=$V" "$WEB/index.html"; then
  docker exec "$C" sed -i -e 's#<script defer src="aurora-home.js?v=[^"]*"></script>##' \
    -e "s#</body>#<script defer src=\"aurora-home.js?v=$V\"></script></body>#" "$WEB/index.html" \
    && echo "index.html enganchado (v=$V)"
fi

if [ "$MODO" = "--cron" ]; then
  mkdir -p "$DIR" && curl -fsSL "$REPO/install/inject-docker.sh" -o "$DIR/inject-docker.sh" && chmod +x "$DIR/inject-docker.sh"
  LINEA="*/10 * * * * $DIR/inject-docker.sh $C >/dev/null 2>&1 # aurora-glass"
  ( crontab -l 2>/dev/null | grep -v "aurora-glass"; echo "$LINEA" ) | crontab - && echo "Programado cada 10 min ($DIR/inject-docker.sh)"
fi
echo "Listo. Recarga la web de Jellyfin con Ctrl+F5."
