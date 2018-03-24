#!/bin/bash

if [ ! -z "$TRAVIS_TAG" ]; then
  curl -T $DEB \
       -H "X-Bintray-Debian-Distribution:wheezy,jessie,stretch" \
       -H "X-Bintray-Debian-Component:main" \
       -H "X-Bintray-Debian-Architecture:${ARCH}" \
       -H "X-Bintray-Publish:1" \
       -ufg2it:${BINTRAY_TOKEN} \
       https://api.bintray.com/content/fg2it/${REPO}/grafana-on-raspberry/${GRAFANA_VERSION}/${COMPONENT}/g/$DEB
fi