#!/bin/bash
set -eou pipefail

# Output delimiter
d="===="

CONNECT_VERSION=${CONNECT_VERSION}
OS_URL=${OS_URL}

echo "$d Fetching Posit Connect package $d"

# fetch latest deb package
curl -fsSL "https://cdn.posit.co/connect/$(echo $CONNECT_VERSION | sed -r 's/([0-9]+\.[0-9]+).*/\1/')/rstudio-connect_${CONNECT_VERSION}~${OS_URL}_amd64.deb" -o /tmp/rstudio-connect.deb

echo "$d Verify Posit Connect package $d"
# Verify the deb package
gpg --keyserver keys.openpgp.org --recv-keys 51C0B5BB19F92D60
gpg --verify /tmp/rstudio-connect.deb

echo "$d Patching rstudio-connect.deb $d"
dpkg --unpack /tmp/rstudio-connect.deb
# The behavior of the post install script is erratic. I'm patching over it like crazy to try to stop Connect from starting up or configuring.
sed -i '/set +e/a RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION="1"' /var/lib/dpkg/info/rstudio-connect.postinst
sed -i 's/systemctl enable rstudio-connect.service/#systemctl enable rstudio-connect.service/g' /var/lib/dpkg/info/rstudio-connect.postinst
sed -i 's/systemctl start rstudio-connect.service/echo "I will not initialize myself."/g' /var/lib/dpkg/info/rstudio-connect.postinst

# install latest deb package
echo "$d Installing rstudio-connect.deb $d"
pti syspkg update
dpkg --configure rstudio-connect
apt-get install -yf

# clean up
pti syspkg clean
rm -f /tmp/rstudio-connect.deb
