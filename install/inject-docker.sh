#!/bin/bash
# Nebula — instala el carrusel en un Jellyfin o Emby en Docker (lo detecta solo) y, opcionalmente,
# pone el tema en «CSS personalizado». Idempotente: ejecutarlo de nuevo no duplica nada.
#
# Una línea (en el servidor):
#   curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/inject-docker.sh | bash -s -- jellyfin --cron
#   curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/inject-docker.sh | bash -s -- emby --cron
#
# Uso:  inject-docker.sh [contenedor] [--cron | --watch | --uninstall]       (contenedor por defecto: jellyfin)
#   (nada)       instala una vez
#   --cron       instala y lo programa cada 10 min en el crontab (se reengancha tras actualizar el servidor)
#   --watch      se queda vigilando en bucle (para el contenedor «nebula» de docker compose)
#   --uninstall  quita el carrusel y el cron (el CSS personalizado no se toca)
# Variables opcionales:
#   JELLYFIN_API_KEY  clave de API (Jellyfin: Panel → Claves API · Emby: Panel → Claves API) — también vale EMBY_API_KEY.
#                     Si está, pone el tema en «CSS personalizado» cuando aún no lo tiene (no toca nada si ya hay algo).
#   NEBULA_OPTIONS    opciones separadas por coma, p. ej. "cabecera-minima,acento-coral" (solo Jellyfin; ver opciones/)
#   INTERVAL          segundos entre comprobaciones con --watch (por defecto 600)
#   SERVER_PORT       puerto interno del servidor si no es el habitual (se detecta solo: 8096, 8097, 8920)
#   JS_URL / WEB      URL del script del carrusel / carpeta web dentro del contenedor (se detectan solos)
set -u
C="${1:-${JELLYFIN_CONTAINER:-${EMBY_CONTAINER:-jellyfin}}}"; MODO="${2:-}"
CDN="https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main"
REPO="https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main"
DIR="${NEBULA_DIR:-$HOME/.nebula-jellyfin}"
KEY="${JELLYFIN_API_KEY:-${EMBY_API_KEY:-}}"

corriendo() { docker inspect -f '{{.State.Running}}' "$C" 2>/dev/null | grep -q true; }

# ¿Jellyfin o Emby? Se mira qué carpeta web tiene el contenedor
detectar() {
  [ -n "${SERVIDOR:-}" ] && return 0
  local d
  for d in ${WEB:-} /jellyfin/jellyfin-web /usr/share/jellyfin/web /app/emby/system/dashboard-ui /app/emby/dashboard-ui /opt/emby-server/system/dashboard-ui /system/dashboard-ui; do
    if docker exec "$C" test -f "$d/index.html" 2>/dev/null; then WEB="$d"; break; fi
  done
  [ -n "${WEB:-}" ] || { echo "No encuentro la web de Jellyfin/Emby dentro de '$C' (usa WEB=/ruta)"; return 1; }
  case "$WEB" in
    *dashboard-ui*) SERVIDOR=emby;     JS=nebula-emby-home.js; JS_SRC="emby/nebula-emby-home.js"; CSS_SRC="emby/nebula-emby.css"; PRE="/emby" ;;
    *)              SERVIDOR=jellyfin; JS=nebula-home.js;      JS_SRC="nebula-home.js";            CSS_SRC="nebula.css";            PRE="" ;;
  esac
  JS_URL="${JS_URL:-$REPO/$JS_SRC}"   # GitHub directo: se actualiza en minutos (jsDelivr @main tarda horas)
  echo "Detectado: $SERVIDOR ($WEB)"
}

carrusel() {
  local TMP L R V; TMP="$(mktemp)"
  # restos de versiones anteriores (Aurora Glass)
  if docker exec "$C" grep -q 'aurora-home.js' "$WEB/index.html" 2>/dev/null; then
    docker exec "$C" sed -i 's#<script defer src="aurora-home.js?v=[^"]*"></script>##' "$WEB/index.html"
    docker exec "$C" rm -f "$WEB/aurora-home.js"; echo "Quitada la versión anterior (Aurora Glass)"
  fi
  curl -fsSL "$JS_URL" -o "$TMP" || { echo "No se pudo descargar $JS_URL"; rm -f "$TMP"; return 1; }
  L=$(md5sum < "$TMP" | cut -c1-32)
  R=$(docker exec "$C" md5sum "$WEB/$JS" 2>/dev/null | cut -c1-32)
  [ "$L" != "$R" ] && docker cp "$TMP" "$C:$WEB/$JS" >/dev/null && echo "$JS copiado"
  rm -f "$TMP"
  V=${L:0:8}
  if ! docker exec "$C" grep -q "$JS?v=$V" "$WEB/index.html"; then
    docker exec "$C" sed -i -e "s#<script defer src=\"$JS?v=[^\"]*\"></script>##" \
      -e "s#</body>#<script defer src=\"$JS?v=$V\"></script></body>#" "$WEB/index.html" \
      && echo "index.html enganchado (v=$V)"
  fi
}

# Puerto interno del servidor: con red «host» el 8096 puede ser OTRO servidor (p. ej. Jellyfin junto a Emby),
# así que se comprueba qué responde en cada puerto.
puerto() {
  local p info
  for p in ${SERVER_PORT:-} 8096 8097 8920; do
    info=$(docker exec "$C" curl -fs -m 4 "http://localhost:$p/System/Info/Public" 2>/dev/null) || continue
    if [ "$SERVIDOR" = jellyfin ]; then printf '%s' "$info" | grep -q '"ProductName":"Jellyfin' && { echo "$p"; return; }
    else printf '%s' "$info" | grep -q 'Jellyfin' || { echo "$p"; return; }; fi
  done
}

tema_css() {
  [ -n "$KEY" ] || return 0
  local P H U B IMP o NB
  P=$(puerto); [ -n "$P" ] || { echo "No encuentro el puerto de $SERVIDOR dentro del contenedor (usa SERVER_PORT=)"; return 0; }
  H="Authorization: MediaBrowser Token=\"$KEY\""
  U="http://localhost:$P$PRE/System/Configuration/branding"
  B=$(docker exec "$C" curl -fs -H "$H" -H "X-Emby-Token: $KEY" "$U") || { echo "No pude leer la configuración (¿clave de API correcta?)"; return 0; }
  printf '%s' "$B" | grep -qiE 'nebula|aurora' && return 0  # ya tiene el tema: no se toca
  local NL='\n'                                     # salto de línea ya escapado para JSON
  IMP="@import url('$CDN/$CSS_SRC');"
  if [ "$SERVIDOR" = jellyfin ]; then
    for o in $(printf '%s' "${NEBULA_OPTIONS:-}" | tr ',' ' '); do IMP="$IMP$NL@import url('$CDN/opciones/${o%.css}.css');"; done
  fi
  NB=$(printf '%s' "$B" | sed 's#"CustomCss":null#"CustomCss":""#' | \
       IMP="$IMP$NL" awk '{ i = index($0, "\"CustomCss\":\""); if (i) $0 = substr($0, 1, i + 12) ENVIRON["IMP"] substr($0, i + 13); print }')
  printf '%s' "$NB" | docker exec -i "$C" curl -fs -o /dev/null -X POST -H "$H" -H "X-Emby-Token: $KEY" -H 'Content-Type: application/json' \
    --data-binary @- "$U" && echo "Tema puesto en «CSS personalizado»"
}

if [ "$MODO" = "--uninstall" ]; then
  if corriendo && detectar; then
    for j in nebula-home.js nebula-emby-home.js aurora-home.js; do
      docker exec "$C" sed -i "s#<script defer src=\"$j?v=[^\"]*\"></script>##" "$WEB/index.html"
      docker exec "$C" rm -f "$WEB/$j"
    done
  fi
  crontab -l 2>/dev/null | grep -vE "nebula-jellyfin|aurora-glass" | crontab - 2>/dev/null
  echo "Carrusel desinstalado. Recarga la web con Ctrl+F5 (el CSS personalizado quítalo a mano si quieres)."; exit 0
fi

if [ "$MODO" = "--watch" ]; then
  echo "Nebula vigilando el contenedor '$C' cada ${INTERVAL:-600}s"
  while :; do
    if corriendo && detectar; then carrusel; tema_css; fi
    sleep "${INTERVAL:-600}"
  done
fi

corriendo || { echo "El contenedor '$C' no está en marcha"; exit 0; }
detectar || exit 1
carrusel; tema_css

if [ "$MODO" = "--cron" ]; then
  mkdir -p "$DIR" && curl -fsSL "$REPO/install/inject-docker.sh" -o "$DIR/inject-docker.sh" && chmod +x "$DIR/inject-docker.sh"
  LINEA="*/10 * * * * $DIR/inject-docker.sh $C >/dev/null 2>&1 # nebula-jellyfin $C"
  ( crontab -l 2>/dev/null | grep -v "nebula-jellyfin $C" | grep -v "aurora-glass"; echo "$LINEA" ) | crontab - && echo "Programado cada 10 min ($DIR/inject-docker.sh)"
fi
echo "Listo. Recarga la web con Ctrl+F5."
