#!/bin/bash
set -eou pipefail

# Output delimiter
d="===="

CONNECT_VERSION=${CONNECT_VERSION}

echo "$d Fetching Posit Connect package $d"

# fetch latest deb package
pti syspkg install -p curl -p dpkg-sig -p gnupg -p gnupg-agent
# TODO: Handle OS-specific builds for Connect
curl -fsSL "https://cdn.posit.co/connect/$(echo $CONNECT_VERSION | sed -r 's/([0-9]+\.[0-9]+).*/\1/')/rstudio-connect_${CONNECT_VERSION}~ubuntu22_amd64.deb" -o /tmp/rstudio-connect.deb

echo "$d Verify Posit Connect package $d"
# Verify the deb package
gpg --keyserver keys.openpgp.org --recv-keys 51C0B5BB19F92D60
dpkg-sig --verify /tmp/rstudio-connect.deb
pti syspkg uninstall -p curl -p dpkg-sig -p gnupg -p gnupg-agent

echo "$d Install Posit Package Manager $d"
pti syspkg update
RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 apt-get install -yf /tmp/rstudio-connect.deb

# clean up
pti syspkg clean
rm /tmp/rstudio-connect.deb
