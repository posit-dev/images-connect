#!/bin/bash

# Output delimiter
d="===="


echo "$d Install Tensorflow package $d"

# fetch latest deb package
pti syspkg install -p curl -p dpkg-sig -p gnupg -p gnupg-agent

curl -fsSL https://storage.googleapis.com/tensorflow-serving-apt/tensorflow-serving.release.pub.gpg | apt-key add -

pti syspkg install tensorflow-model-server-universal

pti syspkg uninstall -p curl -p dpkg-sig -p gnupg -p gnupg-agent

# clean up
pti syspkg clean
