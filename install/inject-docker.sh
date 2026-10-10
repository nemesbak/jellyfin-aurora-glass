#!/bin/bash
# Aurora Glass — instala/actualiza el carrusel (aurora-home.js) en un Jellyfin en Docker.
# Idempotente: puedes ejecutarlo en un cron cada 10 min; si una actualización de la imagen
# borra el script, lo vuelve a poner.
#
# Uso:  ./inject-docker.sh [nombre_contenedor]          (por defecto: jellyfin)
# Variables opcionales:
#   JS_URL   URL de aurora-home.js   (por defecto: la última versión del repo en jsDelivr)
#   WEB      carpeta web dentro del contenedor (por defecto: /jellyfin/jellyfin-web)
set -u
C="${1:-jellyfin}"
WEB="${WEB:-/jellyfin/jellyfin-web}"
JS_URL="${JS_URL:-https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-aurora-glass@main/aurora-home.js}"
TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT

docker inspect -f '{{.State.Running}}' "$C" 2>/dev/null | grep -q true || { echo "Contenedor '$C' no está en marcha"; exit 0; }
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
