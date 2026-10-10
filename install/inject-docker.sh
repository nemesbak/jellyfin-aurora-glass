#!/bin/bash
# Nebula — pone el carrusel en Jellyfin y/o Emby (y, opcionalmente, el tema en «CSS personalizado»).
# Busca solo TODOS los Jellyfin y Emby del equipo: en contenedores Docker o instalados directamente en el sistema.
# Idempotente: ejecutarlo de nuevo no duplica nada. Lo normal es usar install/nebula.sh, que llama a este.
#
# Uso:  inject-docker.sh [contenedor | auto | host] [--cron | --watch | --uninstall]
#   auto (por defecto)  todos los Jellyfin/Emby que encuentre (Docker y sistema)
#   <contenedor>        solo ese contenedor de Docker
#   host                solo la instalación directa en el sistema (sin Docker)
#   --watch             se queda vigilando en bucle (lo usa el contenedor «nebula»)
#   --cron              además lo programa cada 10 min en el crontab
#   --uninstall         quita el carrusel (el CSS personalizado no se toca)
# Variables opcionales:
#   JELLYFIN_API_KEY / EMBY_API_KEY  clave de API: pone el tema en «CSS personalizado» si aún no lo tiene
#                     (nunca borra lo que haya). Con los dos servidores, cada uno usa la suya.
#   NEBULA_OPTIONS    opciones separadas por coma, p. ej. "cabecera-minima,acento-coral" (solo Jellyfin)
#   INTERVAL          segundos entre comprobaciones con --watch (por defecto 600)
#   SERVER_PORT       puerto interno si no es el habitual (se detecta solo: 8096, 8097, 8920)
#   WEB               carpeta web si no está en el sitio habitual
set -u
ARG="${1:-${JELLYFIN_CONTAINER:-${EMBY_CONTAINER:-auto}}}"; MODO="${2:-}"
case "$ARG" in --*) MODO="$ARG"; ARG="${JELLYFIN_CONTAINER:-${EMBY_CONTAINER:-auto}}" ;; esac
CDN="https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-nebula@main"
REPO="https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main"
DIR="${NEBULA_DIR:-$HOME/.nebula-jellyfin}"
WEBS="/jellyfin/jellyfin-web /usr/share/jellyfin/web /usr/lib/jellyfin/bin/jellyfin-web /app/emby/system/dashboard-ui /app/emby/dashboard-ui /opt/emby-server/system/dashboard-ui /system/dashboard-ui /usr/lib/emby-server/system/dashboard-ui /var/lib/emby/dashboard-ui"
HAY_DOCKER=0; command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 && HAY_DOCKER=1

# --- acceso al destino: T = nombre del contenedor, o «host» para el propio sistema ---
x()    { if [ "$T" = host ]; then "$@"; else docker exec "$T" "$@"; fi; }
xi()   { if [ "$T" = host ]; then "$@"; else docker exec -i "$T" "$@"; fi; }
meter() { if [ "$T" = host ]; then cp "$1" "$2" && chmod 644 "$2"; else docker cp "$1" "$T:$2" >/dev/null; fi; }
nombre() { if [ "$T" = host ]; then echo "este equipo"; else echo "el contenedor «$T»"; fi; }

# ¿Jellyfin o Emby? Se mira qué carpeta web tiene
detectar() {
  local d; WEB=""
  for d in ${NEBULA_WEB:-} $WEBS; do
    if x test -f "$d/index.html" 2>/dev/null; then WEB="$d"; break; fi
  done
  [ -n "$WEB" ] || return 1
  case "$WEB" in
    *dashboard-ui*) SERVIDOR=emby;     JS=nebula-emby-home.js; JS_SRC="emby/nebula-emby-home.js"; CSS_SRC="emby/nebula-emby.css"; PRE="/emby"; KEY="${EMBY_API_KEY:-${JELLYFIN_API_KEY:-}}" ;;
    *)              SERVIDOR=jellyfin; JS=nebula-home.js;      JS_SRC="nebula-home.js";            CSS_SRC="nebula.css";            PRE="";      KEY="${JELLYFIN_API_KEY:-${EMBY_API_KEY:-}}" ;;
  esac
  [ -n "${JELLYFIN_API_KEY:-}" ] && [ -n "${EMBY_API_KEY:-}" ] && { [ $SERVIDOR = emby ] && KEY="$EMBY_API_KEY" || KEY="$JELLYFIN_API_KEY"; }
  return 0
}

carrusel() {
  local TMP L R V; TMP="$(mktemp)"
  if x grep -q 'aurora-home.js' "$WEB/index.html" 2>/dev/null; then   # restos de la versión anterior (Aurora Glass)
    x sed -i 's#<script defer src="aurora-home.js?v=[^"]*"></script>##' "$WEB/index.html"; x rm -f "$WEB/aurora-home.js"
  fi
  curl -fsSL "$REPO/$JS_SRC" -o "$TMP" || { echo "  ✗ No se pudo descargar el carrusel (¿hay internet?)"; rm -f "$TMP"; return 1; }
  L=$(md5sum < "$TMP" | cut -c1-32)
  R=$(x md5sum "$WEB/$JS" 2>/dev/null | cut -c1-32)
  [ "$L" != "$R" ] && meter "$TMP" "$WEB/$JS" && echo "  ✓ Carrusel copiado"
  rm -f "$TMP"
  V=${L:0:8}
  if ! x grep -q "$JS?v=$V" "$WEB/index.html"; then
    x sed -i -e "s#<script defer src=\"$JS?v=[^\"]*\"></script>##" \
      -e "s#</body>#<script defer src=\"$JS?v=$V\"></script></body>#" "$WEB/index.html" && echo "  ✓ Carrusel enganchado"
  fi
}

# Puerto interno: con red «host» el 8096 puede ser OTRO servidor (p. ej. Jellyfin junto a Emby)
puerto() {
  local p info
  for p in ${SERVER_PORT:-} 8096 8097 8920; do
    info=$(x curl -fs -m 4 "http://localhost:$p/System/Info/Public" 2>/dev/null) || continue
    if [ "$SERVIDOR" = jellyfin ]; then printf '%s' "$info" | grep -q '"ProductName":"Jellyfin' && { echo "$p"; return; }
    else printf '%s' "$info" | grep -q 'Jellyfin' || { echo "$p"; return; }; fi
  done
}

tema_css() {
  [ -n "$KEY" ] || return 0
  local P H U B IMP o NB NL='\n'
  P=$(puerto); [ -n "$P" ] || { echo "  · No encuentro el puerto de $SERVIDOR (usa SERVER_PORT=)"; return 0; }
  H="Authorization: MediaBrowser Token=\"$KEY\""
  U="http://localhost:$P$PRE/System/Configuration/branding"
  B=$(x curl -fs -H "$H" -H "X-Emby-Token: $KEY" "$U") || { echo "  · No pude leer la configuración (¿clave de API correcta?)"; return 0; }
  printf '%s' "$B" | grep -qiE 'nebula|aurora' && return 0     # ya tiene el tema: no se toca
  IMP="@import url('$CDN/$CSS_SRC');"
  if [ "$SERVIDOR" = jellyfin ]; then
    for o in $(printf '%s' "${NEBULA_OPTIONS:-}" | tr ',' ' '); do IMP="$IMP$NL@import url('$CDN/opciones/${o%.css}.css');"; done
  fi
  NB=$(printf '%s' "$B" | sed 's#"CustomCss":null#"CustomCss":""#' | \
       IMP="$IMP$NL" awk '{ i = index($0, "\"CustomCss\":\""); if (i) $0 = substr($0, 1, i + 12) ENVIRON["IMP"] substr($0, i + 13); print }')
  printf '%s' "$NB" | xi curl -fs -o /dev/null -X POST -H "$H" -H "X-Emby-Token: $KEY" -H 'Content-Type: application/json' \
    --data-binary @- "$U" && echo "  ✓ Tema puesto en «CSS personalizado»"
}

quitar() {
  local j
  for j in nebula-home.js nebula-emby-home.js aurora-home.js; do
    x sed -i "s#<script defer src=\"$j?v=[^\"]*\"></script>##" "$WEB/index.html"
    x rm -f "$WEB/$j"
  done
  echo "  ✓ Carrusel quitado de $SERVIDOR ($(nombre))"
}

# Lista de destinos: contenedores en marcha con Jellyfin/Emby dentro + el propio sistema si lo tiene instalado
destinos() {
  case "$ARG" in
    host) echo host ;;
    auto)
      if [ "$HAY_DOCKER" = 1 ]; then
        docker ps --format '{{.Names}}' | while read -r c; do
          [ "$c" = nebula ] && continue
          T="$c"; detectar && echo "$c"
        done
      fi
      if [ ! -f /.dockerenv ]; then T=host; detectar && echo host; fi ;;
    *) echo "$ARG" ;;
  esac
}

una_pasada() {
  local n=0
  for T in $(destinos); do
    if [ "$T" != host ] && ! docker inspect -f '{{.State.Running}}' "$T" 2>/dev/null | grep -q true; then
      echo "El contenedor «$T» no está en marcha"; continue
    fi
    detectar || { echo "No encuentro Jellyfin ni Emby en $(nombre) (usa NEBULA_WEB=/ruta/a/la/web)"; continue; }
    n=$((n + 1))
    if [ "$MODO" = "--uninstall" ]; then quitar; continue; fi
    echo "▶ $SERVIDOR en $(nombre)"
    carrusel; tema_css
  done
  [ "$n" -gt 0 ] || echo "No he encontrado ningún Jellyfin ni Emby en este equipo."
  [ "$n" -gt 0 ]
}

if [ "$MODO" = "--watch" ]; then
  echo "Nebula vigilando cada ${INTERVAL:-600}s ($ARG)"
  while :; do una_pasada >/dev/null 2>&1 || true; sleep "${INTERVAL:-600}"; done
fi

una_pasada; OK=$?

if [ "$MODO" = "--uninstall" ]; then
  crontab -l 2>/dev/null | grep -vE "nebula-jellyfin|aurora-glass" | crontab - 2>/dev/null
  rm -f /etc/cron.d/nebula 2>/dev/null
  echo "Listo. Recarga la web con Ctrl+F5 (el CSS personalizado quítalo a mano si quieres)."; exit 0
fi

if [ "$MODO" = "--cron" ] && [ $OK = 0 ]; then
  mkdir -p "$DIR" && curl -fsSL "$REPO/install/inject-docker.sh" -o "$DIR/inject-docker.sh" && chmod +x "$DIR/inject-docker.sh"
  LINEA="*/10 * * * * $DIR/inject-docker.sh $ARG >/dev/null 2>&1 # nebula-jellyfin $ARG"
  ( crontab -l 2>/dev/null | grep -v "nebula-jellyfin" | grep -v "aurora-glass"; echo "$LINEA" ) | crontab - && echo "Programado cada 10 min"
fi
[ $OK = 0 ] && echo "Listo. Recarga la web con Ctrl+F5."
exit $OK
