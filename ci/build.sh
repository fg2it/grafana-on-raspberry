#!/bin/bash

set -x

usage() {
  base="$(basename "$0")"
  cat <<EOUSAGE
usage: $base <arch>
Faster grafana build (armv6, armv7 or arm64) reusing offical assets
Available arch:
  $base armv6
  $base armv7
  $base arm64
EOUSAGE
}

install_phjs() {
  PHJSURL="https://github.com/fg2it/phantomjs-on-raspberry/releases/download/${PHJSV}"
  PHJS=/tmp/${ARM}/phantomjs
  mkdir -p /tmp/${ARM}
  if [ ! -f ${PHJS} ]; then
    curl -sSL ${PHJSURL}/phantomjs -o ${PHJS}
    chmod a+x ${PHJS}
  fi
}

armv6_install_cross(){
  if [ ! -d /tmp/cross-rpi1b/ ]; then
    cd /tmp
    git clone https://github.com/fg2it/cross-rpi1b.git
  fi
  CROSSPATH="/tmp/cross-rpi1b/arm-rpi-4.9.3-linux-gnueabihf/bin/"
  CC=${CROSSPATH}/arm-linux-gnueabihf-gcc
}

armv7_install_cross() {
  apt-get install -y gcc-arm-linux-gnueabihf
  CC=arm-linux-gnueabihf-gcc
}

arm64_install_cross() {
  apt-get install -y gcc-aarch64-linux-gnu
  CC=aarch64-linux-gnu-gcc
}

build_bin32() {
  cd $GOPATH/src/github.com/grafana/grafana
  CGO_ENABLED=1 GOARCH=arm GOARM=$1 CC=$CC go build -ldflags "-w -X main.version=${GRAFANA_VERSION} -X main.commit=${commit} -X main.buildstamp=${buildstamp}" \
           -o ./bin/grafana-server ./pkg/cmd/grafana-server
  CGO_ENABLED=1 GOARCH=arm GOARM=$1 CC=$CC go build -ldflags "-w -X main.version=${GRAFANA_VERSION} -X main.commit=${commit} -X main.buildstamp=${buildstamp}" \
           -o ./bin/grafana-cli ./pkg/cmd/grafana-cli
}

build_bin64() {
  cd $GOPATH/src/github.com/grafana/grafana
  CGO_ENABLED=1 GOARCH=${ARM} CC=$CC go build -ldflags "-w -X main.version=${GRAFANA_VERSION} -X main.commit=${commit} -X main.buildstamp=${buildstamp}" \
           -o ./bin/grafana-server ./pkg/cmd/grafana-server
  CGO_ENABLED=1 GOARCH=${ARM} CC=$CC go build -ldflags "-w -X main.version=${GRAFANA_VERSION} -X main.commit=${commit} -X main.buildstamp=${buildstamp}" \
           -o ./bin/grafana-cli ./pkg/cmd/grafana-cli
}

fix_assets(){
  cd $GOPATH/src/github.com/grafana/grafana
  cp ./bin/grafana-server /tmp/deb/usr/sbin/
  cp ./bin/grafana-server /tmp/tgz/grafana-${GRAFANA_VERSION}/bin/
  cp ./bin/grafana-cli /tmp/deb/usr/sbin/
  cp ./bin/grafana-cli /tmp/tgz/grafana-${GRAFANA_VERSION}/bin/
  cp $PHJS /tmp/deb/usr/share/grafana/tools/phantomjs/
  cp $PHJS /tmp/tgz/grafana-${GRAFANA_VERSION}/tools/phantomjs/
}

repack_assets(){
  cd /tmp/tgz
  mkdir -p /tmp/pkg/${ARM}
  tar cfz /tmp/pkg/${ARM}/grafana-${GRAFANA_VERSION}.linux-${ARCH}.tar.gz grafana-${GRAFANA_VERSION}
  cd /tmp/deb
  fpm -t deb -s dir --description Grafana -C /tmp/deb                         \
      --vendor Grafana --url https://grafana.com --license "Apache 2.0"       \
      --maintainer contact@grafana.com                                        \
      --config-files /etc/init.d/grafana-server                               \
      --config-files /etc/default/grafana-server                              \
      --config-files /usr/lib/systemd/system/grafana-server.service           \
      --after-install /tmp/DEBIAN/postinst                                    \
      --name grafana --version "${GRAFANA_VERSION}"                           \
      --deb-no-default-config-files -a ${ARCH}                                \
      --depends adduser --depends libfontconfig -p /tmp/pkg/${ARM} .
}


GRAFANA_VERSION='5.0.3'
cd $GOPATH/src/github.com/grafana/grafana
commit=$(git rev-parse --short HEAD)
buildstamp=$(git show -s --format=%ct)

for ARM in "$@"
do
  case "$ARM" in
    armv6)
      PHJSV="v2.1.1-wheezy-jessie-armv6"
      install_phjs
      armv6_install_cross
      ARCH="armhf"
      build_bin32 6
      ;;
    armv7)
      PHJSV="v2.1.1-wheezy-jessie"
      install_phjs
      armv7_install_cross
      ARCH="armhf"
      build_bin32 7
      ;;
    arm64)
      PHJSV="v2.1.1-jessie-stretch-arm64"
      install_phjs
      arm64_install_cross
      ARCH="arm64"
      build_bin64
      ;;
    *)
      echo >&2 'error: unknown arch:' "$ARM"
      usage >&2
      exit 1
      ;;
  esac
  fix_assets
  repack_assets
done
