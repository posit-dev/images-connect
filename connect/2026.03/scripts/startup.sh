#!/bin/bash

set -e
PCT_STARTUP_DEBUG=${PCT_STARTUP_DEBUG:-$STARTUP_DEBUG_MODE}
if [[ "${PCT_STARTUP_DEBUG:-0}" -eq 1 ]]; then
  set -x
fi

# Deactivate license when it exists (only used for key/server license modes)
deactivate() {
    echo "Deactivating license ..."
    is_deactivated=0
    retries=0
    while [[ $is_deactivated -ne 1 ]] && [[ $retries -le 3 ]]; do
      /opt/rstudio-connect/bin/license-manager deactivate >/dev/null 2>&1
      is_deactivated=1
      ((retries+=1))
      # shellcheck disable=SC2045
      for file in $(ls -A /var/lib/.local); do
        if [ -s "/var/lib/.local/$file" ]; then
          if [[ $retries -lt 3 ]]; then
            echo "License did not deactivate, retry ${retries}..."
            is_deactivated=0
          else
            echo "Unable to deactivate license. If you encounter issues activating your product in the future, please contact Posit support."
          fi
          continue
        fi
      done
    done
}

# Backward compatibility for RSC_ prefixed environment variables
PCT_LICENSE=${PCT_LICENSE:-$RSC_LICENSE}
PCT_LICENSE_SERVER=${PCT_LICENSE_SERVER:-$RSC_LICENSE_SERVER}
PCT_LICENSE_FILE_PATH=${PCT_LICENSE_FILE_PATH:-$RSC_LICENSE_FILE_PATH}

# Activate License
PCT_LICENSE_FILE_PATH=${PCT_LICENSE_FILE_PATH:-/etc/rstudio-connect/license.lic}
if ! [ -z "$PCT_LICENSE" ]; then
    /opt/rstudio-connect/bin/license-manager activate "$PCT_LICENSE"
    trap deactivate EXIT
elif ! [ -z "$PCT_LICENSE_SERVER" ]; then
    /opt/rstudio-connect/bin/license-manager license-server "$PCT_LICENSE_SERVER"
    trap deactivate EXIT
elif test -f "$PCT_LICENSE_FILE_PATH"; then
    # Direct copy avoids activate-file's root requirement and activation-slot lease risk.
    # https://docs.posit.co/connect/admin/licensing/#license-file-activation
    if [ "${PCT_LICENSE_FILE_PATH}" != "/var/lib/rstudio-connect/license.lic" ]; then
        cp "${PCT_LICENSE_FILE_PATH}" /var/lib/rstudio-connect/license.lic
        chmod 0600 /var/lib/rstudio-connect/license.lic
    fi
fi

# ensure these cannot be inherited by child processes
unset PCT_LICENSE
unset PCT_LICENSE_SERVER
unset PCT_LICENSE_FILE_PATH
unset RSC_LICENSE
unset RSC_LICENSE_SERVER
unset RSC_LICENSE_FILE_PATH

# Start RStudio Connect
/opt/rstudio-connect/bin/connect --config /etc/rstudio-connect/rstudio-connect.gcfg
