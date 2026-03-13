#!/bin/bash
set -eou pipefail

# Output delimiter
d="===="

apt-get update -yq

echo "$d Installing Posit Connect 2026.02.0 $d"

RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 apt-get install -yf rstudio-connect=2026.02.0-1
apt-mark hold rstudio-connect

mv /tmp/rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg
if [ "$IMAGE_VARIANT" != "Minimal" ]; then
cat << EOF >> /etc/rstudio-connect/rstudio-connect.gcfg
[R]
Enabled = true
Executable = /opt/R/4.5.2/bin/R

[Python]
Enabled = true
Executable = /opt/python/3.14.3/bin/python

[Quarto]
Enabled = true
Executable = /opt/quarto/1.8.27/bin/quarto

[TensorFlow]
Enabled = true
Executable = /usr/bin/tensorflow_model_server
EOF
else
cat << EOF >> /etc/rstudio-connect/rstudio-connect.gcfg
[Quarto]
Enabled = false

[TensorFlow]
Enabled = false
EOF
fi

# clean up
apt-get clean -yqq && \
rm -rf /var/lib/apt/lists/*
