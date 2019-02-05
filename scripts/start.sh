#!/usr/bin/env bash
set -x

###########################[ PLEX SETUP ]###############################

echo "Starting Plex Media Server."
home="$(echo ~plex)"
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR:-${home}/Library/Application Support}"
export PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver
export PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
export PLEX_MEDIA_SERVER_INFO_DEVICE=docker

if [ ! -d "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}" ]; then
  /bin/mkdir -p "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}"
  chown plex:plex "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}"
fi

chown -R plex:plex /config

if [ -f /config/Library/Application\ Support/Plex\ Media\ Server/plexmediaserver.pid ]; then
    rm -f /config/Library/Application\ Support/Plex\ Media\ Server/plexmediaserver.pid
fi

if [ ! -f /etc/app_configured ]; then
    /scripts/plex-first-run.sh
fi

if [ -f /config/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml ]; then
    # Reset the port in case of update/migration
    sed -i -E 's/ManualPortMappingPort="[0-9]*"/ManualPortMappingPort="'${EXTERNAL_PORT}'"/g' /config/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml
fi

/scripts/plex-update.sh

###########################[ MARK INSTALLED ]###############################

if [ ! -f /etc/app_configured ]; then
    touch /etc/app_configured

    until [[ $(curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST "https://api.cylo.io/v1/apps/installed/${INSTANCE_ID}" | grep '200') ]]
        do
        sleep 5
    done
fi

export LD_LIBRARY_PATH=/usr/lib/plexmediaserver

exec /bin/su -s /bin/bash -c "TERM=xterm /usr/lib/plexmediaserver/Plex\ Media\ Server" plex
