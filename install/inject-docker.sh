#!/bin/bash
# Nebula — instala el carrusel (nebula-home.js) en un Jellyfin en Docker y, opcionalmente,
# pone el tema en «CSS personalizado». Idempotente: ejecutarlo de nuevo no duplica nada.
#
# Una línea (en el servidor):
#   curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/inject-docker.sh | bash -s -- jellyfin --cron
#
# Uso:  inject-docker.sh [contenedor] [--cron | --watch | --uninstall]       (contenedor por defecto: jellyfin)
#   (nada)       instala una vez
#   --cron       instala y lo programa cada 10 min en el crontab (se reengancha tras actualizar Jellyfin)
#   --watch      se queda vigilando en bucle (para el contenedor «nebula» de docker compose)
#   --uninstall  quita el carrusel y el cron (el CSS personalizado no se toca)
# Variables opcionales:
#   JELLYFIN_API_KEY  clave de API (Panel → Claves de API): si está, pone el tema en «CSS personalizado»
#                     cuando aún no lo tiene (no toca nada si ya hay algo de Nebula)
#   NEBULA_OPTIONS    opciones separadas por coma, p. ej. "cabecera-minima,acento-coral" (ver carpeta opciones/)
#   INTERVAL          segundos entre comprobaciones con --watch (por defecto 600)
#   JS_URL / WEB      URL de nebula-home.js / carpeta web dentro del contenedor
set -u
C="${1:-${JELLYFIN_CONTAINER:-jellyfin}}"; MODO="${2:-}"
WEB="${WEB:-/jellyfin/jellyfin-web}"
CDN="https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main"
REPO="https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main"
JS_URL="${JS_URL:-$REPO/nebula-home.js}"   # GitHub directo: se actualiza en minutos (jsDelivr @main tarda horas)
DIR="${NEBULA_DIR:-$HOME/.nebula-jellyfin}"

corriendo() { docker inspect -f '{{.State.Running}}' "$C" 2>/dev/null | grep -q true; }

carrusel() {
  local TMP L R V; TMP="$(mktemp)"
  # restos de la versión anterior (Aurora Glass)
  if docker exec "$C" grep -q 'aurora-home.js' "$WEB/index.html" 2>/dev/null; then
    docker exec "$C" sed -i 's#<script defer src="aurora-home.js?v=[^"]*"></script>##' "$WEB/index.html"
    docker exec "$C" rm -f "$WEB/aurora-home.js"; echo "Quitada la versión anterior (Aurora Glass)"
  fi
  curl -fsSL "$JS_URL" -o "$TMP" || { echo "No se pudo descargar $JS_URL"; rm -f "$TMP"; return 1; }
  L=$(md5sum < "$TMP" | cut -c1-32)
  R=$(docker exec "$C" md5sum "$WEB/nebula-home.js" 2>/dev/null | cut -c1-32)
  [ "$L" != "$R" ] && docker cp "$TMP" "$C:$WEB/nebula-home.js" >/dev/null && echo "nebula-home.js copiado"
  rm -f "$TMP"
  V=${L:0:8}
  if ! docker exec "$C" grep -q "nebula-home.js?v=$V" "$WEB/index.html"; then
    docker exec "$C" sed -i -e 's#<script defer src="nebula-home.js?v=[^"]*"></script>##' \
      -e "s#</body>#<script defer src=\"nebula-home.js?v=$V\"></script></body>#" "$WEB/index.html" \
      && echo "index.html enganchado (v=$V)"
  fi
}

tema_css() {
  [ -n "${JELLYFIN_API_KEY:-}" ] || return 0
  local H B IMP o NB
  H="Authorization: MediaBrowser Token=\"$JELLYFIN_API_KEY\""
  B=$(docker exec "$C" curl -fs -H "$H" http://localhost:8096/System/Configuration/branding) || { echo "No pude leer la configuración (¿clave de API correcta?)"; return 0; }
  printf '%s' "$B" | grep -qiE 'nebula|aurora' && return 0  # ya tiene el tema (o el antiguo Aurora Glass): no se toca
  local NL='\n'                                     # salto de línea ya escapado para JSON
  IMP="@import url('$CDN/nebula.css');"
  for o in $(printf '%s' "${NEBULA_OPTIONS:-}" | tr ',' ' '); do IMP="$IMP$NL@import url('$CDN/opciones/${o%.css}.css');"; done
  NB=$(printf '%s' "$B" | sed 's#"CustomCss":null#"CustomCss":""#' | \
       IMP="$IMP$NL" awk '{ i = index($0, "\"CustomCss\":\""); if (i) $0 = substr($0, 1, i + 12) ENVIRON["IMP"] substr($0, i + 13); print }')
  printf '%s' "$NB" | docker exec -i "$C" curl -fs -o /dev/null -X POST -H "$H" -H 'Content-Type: application/json' \
    --data-binary @- http://localhost:8096/System/Configuration/branding && echo "Tema puesto en «CSS personalizado»"
}

if [ "$MODO" = "--uninstall" ]; then
  corriendo && docker exec "$C" sed -i 's#<script defer src="nebula-home.js?v=[^"]*"></script>##' "$WEB/index.html"
  corriendo && docker exec "$C" rm -f "$WEB/nebula-home.js"
  corriendo && docker exec "$C" sed -i 's#<script defer src="aurora-home.js?v=[^"]*"></script>##' "$WEB/index.html"
  crontab -l 2>/dev/null | grep -vE "nebula-jellyfin|aurora-glass" | crontab - 2>/dev/null
  echo "Carrusel desinstalado. Recarga la web con Ctrl+F5 (el CSS personalizado quítalo a mano si quieres)."; exit 0
fi

if [ "$MODO" = "--watch" ]; then
  echo "Nebula vigilando el contenedor '$C' cada ${INTERVAL:-600}s"
  while :; do
    if corriendo; then carrusel; tema_css; fi
    sleep "${INTERVAL:-600}"
  done
fi

corriendo || { echo "El contenedor '$C' no está en marcha"; exit 0; }
carrusel; tema_css

if [ "$MODO" = "--cron" ]; then
  mkdir -p "$DIR" && curl -fsSL "$REPO/install/inject-docker.sh" -o "$DIR/inject-docker.sh" && chmod +x "$DIR/inject-docker.sh"
  LINEA="*/10 * * * * $DIR/inject-docker.sh $C >/dev/null 2>&1 # nebula-jellyfin"
  ( crontab -l 2>/dev/null | grep -vE "nebula-jellyfin|aurora-glass"; echo "$LINEA" ) | crontab - && echo "Programado cada 10 min ($DIR/inject-docker.sh)"
fi
echo "Listo. Recarga la web de Jellyfin con Ctrl+F5."
