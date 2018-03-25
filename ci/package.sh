#!/bin/bash

set -x

ASSETS=${ASSETS:-/tmp/assets}
GRAFANA_VERSION=${GRAFANA_VERSION:-5.0.3}
FPM_DOCKER_TAG=${FPM_DOCKER_TAG:-1.9.3}

usage() {
  base="$(basename "$0")"
  cat <<EOUSAGE
usage: $base <arch>
Package grafana (armv6, armv7 or arm64) reusing offical assets
Available arch:
  $base armv6
  $base armv7
  $base arm64
EOUSAGE
}

package_assets(){
    docker run --rm -v assets-fgbw:${ASSETS} debian:stretch                \
      tar cfz                                                              \
          ${ASSETS}/${ARM}/grafana-${GRAFANA_VERSION}.linux-${ARCH}.tar.gz \
          -C ${ASSETS}/tgz                                                 \
          grafana-${GRAFANA_VERSION}

    docker run --rm -v assets-fgbw:${ASSETS} fg2it/fpm:${FPM_DOCKER_TAG}   \
      fpm -t deb -s dir --description Grafana -C ${ASSETS}/deb          \
      --vendor Grafana --url https://grafana.com --license "Apache 2.0" \
      --maintainer contact@grafana.com                                  \
      --config-files /etc/init.d/grafana-server                         \
      --config-files /etc/default/grafana-server                        \
      --config-files /usr/lib/systemd/system/grafana-server.service     \
      --after-install ${ASSETS}/DEBIAN/postinst                         \
      --name grafana --version "${GRAFANA_VERSION}"                     \
      --deb-no-default-config-files -a ${ARCH}                          \
      --depends adduser --depends libfontconfig -p ${ASSETS}/${ARM}/ .

    docker run --name assets -v assets-fgbw:/tmp/assets/ debian:stretch echo "Extracting $ARM"
    docker cp assets:${ASSETS}/${ARM} ./${ARM}
    docker rm assets
}

ARM=$1

case "$ARM" in
  armv6)
    ARCH="armhf"
    ;;
  armv7)
    ARCH="armhf"
    ;;
  arm64)
    ARCH="arm64"
    ;;
  *)
    echo >&2 'error: unknown arch:' "$ARM"
    usage >&2
    exit 1
    ;;
esac

package_assets