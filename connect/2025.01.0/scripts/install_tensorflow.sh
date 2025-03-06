#!/bin/bash

set -eou pipefail

# Output delimiter
d="===="


echo "$d Install Tensorflow package $d"

# fetch latest deb package
pti syspkg update
pti syspkg install -p curl

curl -fsSL https://storage.googleapis.com/tensorflow-serving-apt/tensorflow-serving.release.pub.gpg -o /usr/share/keyrings/tensorflow-serving.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/tensorflow-serving.gpg] http://storage.googleapis.com/tensorflow-serving-apt stable tensorflow-model-server tensorflow-model-server-universal" | tee /etc/apt/sources.list.d/tensorflow-serving.list

pti syspkg install -p tensorflow-model-server

# clean up
pti syspkg clean
