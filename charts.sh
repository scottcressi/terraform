#!/usr/local/env sh

# open distro
git clone https://github.com/opendistro-for-elasticsearch/opendistro-build.git /var/tmp/opendistro
cd /var/tmp/opendistro/helm/opendistro-es || exit
git pull
git checkout v1.12.0
helm package .

# docker-registry-ui
git clone https://github.com/Joxit/docker-registry-ui.git /var/tmp/docker-registry-ui
cd /var/tmp/docker-registry-ui || exit
git pull
git checkout 1.5.2
