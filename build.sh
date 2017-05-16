#!/usr/bin/env bash

set -e

[ -n "$OCTOPI_OCTOPUS_MAN_IMAGE" ] || OCTOPI_OCTOPUS_MAN_IMAGE='xdissent/octopi'
[ -n "$OCTOPI_OCTOPUS_MAN_VARIANT" ] || OCTOPI_OCTOPUS_MAN_VARIANT='octopus-man'

if [ -e build ]; then
  echo 'Removing old build'
  rm -rf build
fi

read -p 'Pi user password: ' OCTOPI_OCTOPUS_MAN_PASSWORD

read -p 'Pi SSH pubkey (path or hash): ' OCTOPI_OCTOPUS_MAN_SSH_KEY_FILE

if [[ "$OCTOPI_OCTOPUS_MAN_SSH_KEY_FILE" == ssh-* ]]; then
  OCTOPI_OCTOPUS_MAN_SSH_KEY="$OCTOPI_OCTOPUS_MAN_SSH_KEY_FILE"
else
  OCTOPI_OCTOPUS_MAN_SSH_KEY=$(cat "${OCTOPI_OCTOPUS_MAN_SSH_KEY_FILE/#~/$HOME}")
fi

read -p 'Wifi SSID: ' OCTOPI_OCTOPUS_MAN_WIFI_SSID

read -p 'Wifi passphrase: ' OCTOPI_OCTOPUS_MAN_WIFI_PSK

read -p 'Octoprint user: ' OCTOPI_OCTOPUS_MAN_OCTOPRINT_USER

read -p 'Octoprint password: ' OCTOPI_OCTOPUS_MAN_OCTOPRINT_PASSWORD

echo 'Building docker image'
docker build -t "$OCTOPI_OCTOPUS_MAN_IMAGE" .

CID=$(docker run --privileged -d \
  -e "OCTOPI_OCTOPUS_MAN_PASSWORD=$OCTOPI_OCTOPUS_MAN_PASSWORD" \
  -e "OCTOPI_OCTOPUS_MAN_SSH_KEY=$OCTOPI_OCTOPUS_MAN_SSH_KEY" \
  -e "OCTOPI_OCTOPUS_MAN_WIFI_SSID=$OCTOPI_OCTOPUS_MAN_WIFI_SSID" \
  -e "OCTOPI_OCTOPUS_MAN_WIFI_PSK=$OCTOPI_OCTOPUS_MAN_WIFI_PSK" \
  -e "OCTOPI_OCTOPUS_MAN_OCTOPRINT_USER=$OCTOPI_OCTOPUS_MAN_OCTOPRINT_USER" \
  -e "OCTOPI_OCTOPUS_MAN_OCTOPRINT_PASSWORD=$OCTOPI_OCTOPUS_MAN_OCTOPRINT_PASSWORD" \
  "$OCTOPI_OCTOPUS_MAN_IMAGE" \
  "$OCTOPI_OCTOPUS_MAN_VARIANT")

echo "Building octopi in container $CID"
docker logs -f "$CID"

echo 'Copying image from container'
docker cp "$CID:/octopi/src/workspace-octopus-man" build
