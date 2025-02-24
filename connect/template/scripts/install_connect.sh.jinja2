#!/bin/bash
set -eou pipefail

# Output delimiter
d="===="

PYTHON_VERSION=${PYTHON_VERSION}
R_VERSION=${R_VERSION}
SCRIPTS_DIR=${SCRIPTS_DIR:-/opt/posit/scripts}
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
# install latest deb package, dont initialize
RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 apt-get install -yf /tmp/rstudio-connect.deb

PCT_CONFIG_FILE="/etc/rstudio-connect/rstudio-pm.gcfg"

if [ -n "$R_VERSION" ] && [ -n "$PYTHON_VERSION" ]
then
    # The default rstudio-pm.gcfg has an RVersion section already, let's comment that out.
    sed -i 's/RVersion =/;RVersion =/' $PCT_CONFIG_FILE

    echo "$d Setting R and Python version configuration $d"
    cat << EOF >> $PCT_CONFIG_FILE
[Server]
; provided during automated install
RVersion = /opt/R/${R_VERSION}
PythonVersion = /opt/python/${PYTHON_VERSION}/bin/python
EOF
else
    echo "$d No R or Python version provided $d"
fi

# clean up
pti syspkg clean
rm /tmp/rstudio-connect.deb
