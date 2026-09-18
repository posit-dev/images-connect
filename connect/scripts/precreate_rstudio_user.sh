#!/bin/bash
set -euo pipefail

# Pre-create rstudio-connect so the deb postinst finds it and UID/GID stays 999
# across image rebuilds. Idempotent so a cached layer (or the postinst) that already
# created the account does not fail the build.
if ! getent group rstudio-connect >/dev/null; then
    groupadd --system --gid 999 rstudio-connect
fi
if ! getent passwd rstudio-connect >/dev/null; then
    useradd --system --uid 999 --gid rstudio-connect \
        --no-create-home --home-dir /var/lib/rstudio-connect \
        --shell /usr/sbin/nologin \
        rstudio-connect
fi
if [ "$(id -u rstudio-connect)" != 999 ] || [ "$(id -g rstudio-connect)" != 999 ]; then
    echo "ERROR: rstudio-connect must be uid/gid 999, got uid=$(id -u rstudio-connect) gid=$(id -g rstudio-connect)" >&2
    exit 1
fi
