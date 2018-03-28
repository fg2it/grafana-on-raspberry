#!/bin/bash

set -x

ASSETS=${ASSETS:-/tmp/assets}
GRAFANA_VERSION=${GRAFANA_VERSION:-5.0.3}
FPM_DOCKER_TAG=${FPM_DOCKER_TAG:-1.9.3}

usage() {
  base="$(basename "$0")"
  cat <<EOUSAGE
usage: $base <arch>
Package grafana (armv6, armv7 or arm64 on linux, osx64 and win64) reusing offical assets
Available arch:
  $base armv6
  $base armv7
  $base arm64
  $base osx64
  $base win64
EOUSAGE
}

arm_package_assets(){
    docker run --rm -v assets-fgbw:${ASSETS} debian:stretch                \
      tar cfz                                                              \
          ${ASSETS}/${TARGET}/grafana-${GRAFANA_VERSION}.linux-${ARCH}.tar.gz \
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
      --depends adduser --depends libfontconfig -p ${ASSETS}/${TARGET}/ .

    docker run --name assets -v assets-fgbw:/tmp/assets/ debian:stretch echo "Extracting $TARGET"
    docker cp assets:${ASSETS}/${TARGET} ./${TARGET}
    docker rm assets
}

TARGET=$1


osx64_package_assets(){
#because zip not include in debian:stretch ...
  docker run --rm -v assets-fgbw:${ASSETS} fg2it/fgbw:all  /bin/sh -c  \
      "cd ${ASSETS}/tgz/ && zip -r ${ASSETS}/${TARGET}/grafana-${GRAFANA_VERSION}.macosx-x64.zip grafana-${GRAFANA_VERSION}"

  docker run --name assets -v assets-fgbw:/tmp/assets/ debian:stretch echo "Extracting $TARGET"
  docker cp assets:${ASSETS}/${TARGET} ./${TARGET}
  docker rm assets
}

win64_package_assets(){
#because zip not include in debian:stretch ...
  docker run --rm -v assets-fgbw:${ASSETS} fg2it/fgbw:all  /bin/sh -c  \
      "cd ${ASSETS}/tgz/ && zip -r ${ASSETS}/${TARGET}/grafana-${GRAFANA_VERSION}.windows-x64.zip grafana-${GRAFANA_VERSION}"

  docker run --name assets -v assets-fgbw:/tmp/assets/ debian:stretch echo "Extracting $TARGET"
  docker cp assets:${ASSETS}/${TARGET} ./${TARGET}
  docker rm assets
}

case "$TARGET" in
  armv6)
    ARCH="armhf"
    arm_package_assets
    ;;
  armv7)
    ARCH="armhf"
    arm_package_assets
    ;;
  arm64)
    ARCH="arm64"
    arm_package_assets
    ;;
  osx64)
    osx64_package_assets
    ;;
  win64)
    win64_package_assets
    ;;
  *)
    echo >&2 'error: unknown arch:' "$TARGET"
    usage >&2
    exit 1
    ;;
esac

