#!/bin/bash
# Nebula — instalador del carrusel para Jellyfin y Emby. Un solo comando en cualquier sistema:
#
#   curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/nebula.sh | bash
#
# Busca solo todos los Jellyfin y Emby del equipo:
#   · en Docker (Unraid, Docker, Compose, Portainer, Synology, Docker dentro de un LXC…): crea un contenedor
#     pequeñito «nebula» que pone el carrusel y lo vuelve a poner tras cada actualización y cada reinicio.
#   · instalados directamente (LXC de Proxmox, Debian, Ubuntu…): lo pone y deja una tarea cada 10 min.
#
# Quitarlo:   curl -fsSL https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main/install/nebula.sh | bash -s -- --uninstall
# Opcional:   JELLYFIN_API_KEY=… / EMBY_API_KEY=…  delante de «bash» para que ponga también el tema él solo.
set -u
REPO="https://raw.githubusercontent.com/nemesbak/jellyfin-nebula/main"
INYECTOR="$REPO/install/inject-docker.sh"
MODO="${1:-}"

if [ "$(id -u)" != 0 ]; then
  echo "Hace falta ser administrador. Vuelve a pegarlo poniendo «sudo» delante de «bash»:"
  echo "  curl -fsSL $REPO/install/nebula.sh | sudo bash"
  exit 1
fi
command -v curl >/dev/null || { echo "Falta «curl». Instálalo (p. ej. apt install curl) y vuelve a intentarlo."; exit 1; }

echo "✨ Nebula — buscando Jellyfin y Emby…"
HAY_DOCKER=0; command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 && HAY_DOCKER=1
EN_DOCKER=""
if [ "$HAY_DOCKER" = 1 ]; then
  for c in $(docker ps --format '{{.Names}}'); do
    case "$c" in nebula|nebula-emby) continue ;; esac
    docker exec "$c" sh -c 'for d in /jellyfin/jellyfin-web /usr/share/jellyfin/web /usr/lib/jellyfin/bin/jellyfin-web /app/emby/system/dashboard-ui /app/emby/dashboard-ui /opt/emby-server/system/dashboard-ui /system/dashboard-ui; do [ -f "$d/index.html" ] && exit 0; done; exit 1' >/dev/null 2>&1 \
      && EN_DOCKER="$EN_DOCKER $c"
  done
fi

# ---------- quitar ----------
if [ "$MODO" = "--uninstall" ]; then
  [ "$HAY_DOCKER" = 1 ] && docker rm -f nebula nebula-emby >/dev/null 2>&1 && echo "  ✓ Contenedor «nebula» borrado"
  rm -f /etc/cron.d/nebula /usr/local/bin/nebula-inject
  curl -fsSL "$INYECTOR" | bash -s -- auto --uninstall
  exit 0
fi

# ---------- Docker: contenedor vigilante ----------
if [ -n "$EN_DOCKER" ]; then
  echo "  Encontrado en Docker:$EN_DOCKER"
  docker rm -f nebula nebula-emby >/dev/null 2>&1          # versión anterior, si la hay
  docker run -d --name nebula --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e JELLYFIN_API_KEY="${JELLYFIN_API_KEY:-}" -e EMBY_API_KEY="${EMBY_API_KEY:-}" -e NEBULA_OPTIONS="${NEBULA_OPTIONS:-}" \
    docker:cli sh -c "apk add -q --no-cache bash curl && curl -fsSL $INYECTOR | bash -s -- auto --watch" >/dev/null \
    || { echo "  ✗ No pude crear el contenedor «nebula»"; exit 1; }
  echo "  ✓ Contenedor «nebula» creado (se encarga de todo, también tras actualizar o reiniciar)"
  # primera pasada ya, sin esperar a que el contenedor arranque
  curl -fsSL "$INYECTOR" | bash -s -- auto | sed 's/^/  /'
fi

# ---------- instalación directa en el sistema ----------
NATIVO=0
for d in /usr/share/jellyfin/web /usr/lib/jellyfin/bin/jellyfin-web /opt/emby-server/system/dashboard-ui /usr/lib/emby-server/system/dashboard-ui /var/lib/emby/dashboard-ui; do
  [ -f "$d/index.html" ] && NATIVO=1
done
if [ "$NATIVO" = 1 ]; then
  echo "  Encontrado instalado en el sistema"
  curl -fsSL "$INYECTOR" -o /usr/local/bin/nebula-inject && chmod +x /usr/local/bin/nebula-inject
  /usr/local/bin/nebula-inject host | sed 's/^/  /'
  {
    echo "# Nebula: vuelve a poner el carrusel tras las actualizaciones de Jellyfin/Emby"
    [ -n "${JELLYFIN_API_KEY:-}" ] && echo "JELLYFIN_API_KEY=$JELLYFIN_API_KEY"
    [ -n "${EMBY_API_KEY:-}" ] && echo "EMBY_API_KEY=$EMBY_API_KEY"
    [ -n "${NEBULA_OPTIONS:-}" ] && echo "NEBULA_OPTIONS=$NEBULA_OPTIONS"
    echo "*/10 * * * * root /usr/local/bin/nebula-inject host >/dev/null 2>&1"
  } > /etc/cron.d/nebula
  chmod 644 /etc/cron.d/nebula
  echo "  ✓ Se volverá a poner solo cada 10 minutos"
fi

if [ -z "$EN_DOCKER" ] && [ "$NATIVO" = 0 ]; then
  echo
  echo "No he encontrado Jellyfin ni Emby en este equipo."
  echo "  · Proxmox: pégalo DENTRO del contenedor LXC o la máquina virtual donde está Jellyfin/Emby"
  echo "    (en el LXC: botón «Console»), no en el propio Proxmox."
  echo "  · Docker: comprueba que el contenedor de Jellyfin/Emby está encendido."
  exit 1
fi

echo
echo "🎉 ¡Listo! Abre Jellyfin/Emby y recarga con Ctrl+F5 para ver el carrusel."
echo "   ¿Aún no tienes el tema? Mira «Instalación del tema» en https://github.com/nemesbak/jellyfin-nebula"
