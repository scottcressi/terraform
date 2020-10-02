#!/usr/bin/env bash

# open distro
git clone https://github.com/opendistro-for-elasticsearch/opendistro-build.git /var/tmp/opendistro-build
cd /var/tmp/opendistro-build/helm/opendistro-es || exit
git pull
git checkout v1.10.1
helm package .

# docker-registry-ui
git clone https://github.com/Joxit/docker-registry-ui.git /var/tmp/docker-registry-ui
cd /var/tmp/docker-registry-ui || exit
git pull
git checkout 1.5.0
