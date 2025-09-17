#!/bin/bash
set -euo pipefail

RSC_VERSION_URL=$(echo -n "${CONNECT_VERSION}" | sed 's/+/%2B/g')
RSC_VERSION_CLEAN=$(echo -n "${CONNECT_VERSION}" | sed -r 's/([0-9]+\.[0-9]+).*/\1/')

mkdir -p /rsc-staging
curl -fsSL \
  -o /rsc-staging/rstudio-connect-runtime.tar.gz \
  "https://cdn.posit.co/connect/${RSC_VERSION_CLEAN}/rstudio-connect-runtime-${RSC_VERSION_URL}.tar.gz"

mkdir -p /opt/rstudio-connect-runtime
tar -C /opt/rstudio-connect-runtime -xf /rsc-staging/rstudio-connect-runtime.tar.gz
chmod -R 755 /opt/rstudio-connect-runtime
rm -rf /rsc-staging
