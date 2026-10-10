#!/bin/bash
# Aurora Glass — instala el carrusel (aurora-home.js) en un Jellyfin en Docker y, opcionalmente,
# pone el tema en «CSS personalizado». Idempotente: ejecutarlo de nuevo no duplica nada.
#
# Una línea (en el servidor):
#   curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-aurora-glass/main/install/inject-docker.sh | bash -s -- jellyfin --cron
#
# Uso:  inject-docker.sh [contenedor] [--cron | --watch | --uninstall]       (contenedor por defecto: jellyfin)
#   (nada)       instala una vez
#   --cron       instala y lo programa cada 10 min en el crontab (se reengancha tras actualizar Jellyfin)
#   --watch      se queda vigilando en bucle (para el contenedor «aurora-glass» de docker compose)
#   --uninstall  quita el carrusel y el cron (el CSS personalizado no se toca)
# Variables opcionales:
#   JELLYFIN_API_KEY  clave de API (Panel → Claves de API): si está, pone el tema en «CSS personalizado»
#                     cuando aún no lo tiene (no toca nada si ya hay algo de Aurora Glass)
#   AURORA_OPTIONS    opciones separadas por coma, p. ej. "cabecera-minima,acento-coral" (ver carpeta opciones/)
#   INTERVAL          segundos entre comprobaciones con --watch (por defecto 600)
#   JS_URL / WEB      URL de aurora-home.js / carpeta web dentro del contenedor
set -u
C="${1:-${JELLYFIN_CONTAINER:-jellyfin}}"; MODO="${2:-}"
WEB="${WEB:-/jellyfin/jellyfin-web}"
CDN="https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-aurora-glass@main"
REPO="https://raw.githubusercontent.com/nemesbak/jellyfin-aurora-glass/main"
JS_URL="${JS_URL:-$REPO/aurora-home.js}"   # GitHub directo: se actualiza en minutos (jsDelivr @main tarda horas)
DIR="${AURORA_DIR:-$HOME/.aurora-glass}"

corriendo() { docker inspect -f '{{.State.Running}}' "$C" 2>/dev/null | grep -q true; }

carrusel() {
  local TMP L R V; TMP="$(mktemp)"
  curl -fsSL "$JS_URL" -o "$TMP" || { echo "No se pudo descargar $JS_URL"; rm -f "$TMP"; return 1; }
  L=$(md5sum < "$TMP" | cut -c1-32)
  R=$(docker exec "$C" md5sum "$WEB/aurora-home.js" 2>/dev/null | cut -c1-32)
  [ "$L" != "$R" ] && docker cp "$TMP" "$C:$WEB/aurora-home.js" >/dev/null && echo "aurora-home.js copiado"
  rm -f "$TMP"
  V=${L:0:8}
  if ! docker exec "$C" grep -q "aurora-home.js?v=$V" "$WEB/index.html"; then
    docker exec "$C" sed -i -e 's#<script defer src="aurora-home.js?v=[^"]*"></script>##' \
      -e "s#</body>#<script defer src=\"aurora-home.js?v=$V\"></script></body>#" "$WEB/index.html" \
      && echo "index.html enganchado (v=$V)"
  fi
}

tema_css() {
  [ -n "${JELLYFIN_API_KEY:-}" ] || return 0
  local H B IMP o NB
  H="Authorization: MediaBrowser Token=\"$JELLYFIN_API_KEY\""
  B=$(docker exec "$C" curl -fs -H "$H" http://localhost:8096/System/Configuration/branding) || { echo "No pude leer la configuración (¿clave de API correcta?)"; return 0; }
  printf '%s' "$B" | grep -qi 'aurora' && return 0          # ya tiene el tema: no se toca
  local NL='\n'                                     # salto de línea ya escapado para JSON
  IMP="@import url('$CDN/aurora-glass.css');"
  for o in $(printf '%s' "${AURORA_OPTIONS:-}" | tr ',' ' '); do IMP="$IMP$NL@import url('$CDN/opciones/${o%.css}.css');"; done
  NB=$(printf '%s' "$B" | sed 's#"CustomCss":null#"CustomCss":""#' | \
       IMP="$IMP$NL" awk '{ i = index($0, "\"CustomCss\":\""); if (i) $0 = substr($0, 1, i + 12) ENVIRON["IMP"] substr($0, i + 13); print }')
  printf '%s' "$NB" | docker exec -i "$C" curl -fs -o /dev/null -X POST -H "$H" -H 'Content-Type: application/json' \
    --data-binary @- http://localhost:8096/System/Configuration/branding && echo "Tema puesto en «CSS personalizado»"
}

if [ "$MODO" = "--uninstall" ]; then
  corriendo && docker exec "$C" sed -i 's#<script defer src="aurora-home.js?v=[^"]*"></script>##' "$WEB/index.html"
  corriendo && docker exec "$C" rm -f "$WEB/aurora-home.js"
  crontab -l 2>/dev/null | grep -v "aurora-glass" | crontab - 2>/dev/null
  echo "Carrusel desinstalado. Recarga la web con Ctrl+F5 (el CSS personalizado quítalo a mano si quieres)."; exit 0
fi

if [ "$MODO" = "--watch" ]; then
  echo "Aurora Glass vigilando el contenedor '$C' cada ${INTERVAL:-600}s"
  while :; do
    if corriendo; then carrusel; tema_css; fi
    sleep "${INTERVAL:-600}"
  done
fi

corriendo || { echo "El contenedor '$C' no está en marcha"; exit 0; }
carrusel; tema_css

if [ "$MODO" = "--cron" ]; then
  mkdir -p "$DIR" && curl -fsSL "$REPO/install/inject-docker.sh" -o "$DIR/inject-docker.sh" && chmod +x "$DIR/inject-docker.sh"
  LINEA="*/10 * * * * $DIR/inject-docker.sh $C >/dev/null 2>&1 # aurora-glass"
  ( crontab -l 2>/dev/null | grep -v "aurora-glass"; echo "$LINEA" ) | crontab - && echo "Programado cada 10 min ($DIR/inject-docker.sh)"
fi
echo "Listo. Recarga la web de Jellyfin con Ctrl+F5."
