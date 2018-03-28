#!/bin/bash

set -x

usage() {
  base="$(basename "$0")"
  cat <<EOUSAGE
usage: $base <arch>
Build grafana binaries (armv6, armv7 or arm64 on linux and win64) and prepare packaging reusing offical assets
Available arch:
  $base armv6
  $base armv7
  $base arm64
  $base win64
EOUSAGE
}

install_phjs() {
  PHJSURL="https://github.com/fg2it/phantomjs-on-raspberry/releases/download/${PHJSV}"
  PHJS=/tmp/${ARM}/phantomjs
  mkdir -p /tmp/${ARM}
  if [ ! -f ${PHJS} ]; then
    curl -L ${PHJSURL}/phantomjs -o ${PHJS}
    chmod a+x ${PHJS}
  fi
  
}

install_win64_phjs() {
  PHJSURL="https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-windows.zip"
  PHJS=/tmp/${ARM}/phantomjs.exe
  mkdir -p /tmp/${ARM}
  if [ ! -f ${PHJS} ]; then
    curl -L ${PHJSURL} -o /tmp/${ARM}/phantomjs-2.1.1-windows.zip
    cd /tmp/${ARM}
    unzip phantomjs-2.1.1-windows.zip
    mv /tmp/${ARM}/phantomjs-2.1.1-windows/bin/phantomjs.exe ${PHJS}
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

win64_install_cross() {
  apt-get install -y gcc-mingw-w64
  CC=x86_64-w64-mingw32-gcc-posix
}

build_bin() {
  cd $GOPATH/src/github.com/grafana/grafana
  PREF="CGO_ENABLED=1 CC=$CC "
  if [ "$ARM" == "arm64" ]; then
    PREF+="GOARCH=${ARM}"
  elif [ "$ARM" == "win64" ]; then
    CGO_NTDEF="-D_WIN32_WINNT=0x0400"
    PREF+="GOOS=windows GOARCH=amd64 CGO_CFLAGS=$CGO_NTDEF"
  else
    PREF+="GOARCH=arm GOARM=${ARM:4}"
  fi
  eval "$PREF go install -v ./pkg/cmd/grafana-server"
  eval "$PREF go build -ldflags \"-w -X main.version=${GRAFANA_VERSION} -X main.commit=${commit} -X main.buildstamp=${buildstamp}\" \
           -o ./bin/grafana-server ./pkg/cmd/grafana-server"
  eval "$PREF go build -ldflags \"-w -X main.version=${GRAFANA_VERSION} -X main.commit=${commit} -X main.buildstamp=${buildstamp}\" \
           -o ./bin/grafana-cli ./pkg/cmd/grafana-cli"
}

fix_assets(){
  cd $GOPATH/src/github.com/grafana/grafana
  if [ "$ARM" == "win64" ]; then
    EXE='.exe'
  else
    EXE=''
    cp ./bin/grafana-server ${ASSETS}/deb/usr/sbin/grafana-server
    cp ./bin/grafana-cli ${ASSETS}/deb/usr/sbin/
    cp $PHJS ${ASSETS}/deb/usr/share/grafana/tools/phantomjs/
  fi

  cp ./bin/grafana-server ${ASSETS}/tgz/grafana-${GRAFANA_VERSION}/bin/grafana-server${EXE}
  cp ./bin/grafana-cli ${ASSETS}/tgz/grafana-${GRAFANA_VERSION}/bin/grafana-cli${EXE}
  cp $PHJS ${ASSETS}/tgz/grafana-${GRAFANA_VERSION}/tools/phantomjs/

  mkdir -p ${ASSETS}/${ARM}
}

cd $GOPATH/src/github.com/grafana/grafana
commit=$(git rev-parse --short HEAD)
buildstamp=$(git show -s --format=%ct)
GRAFANA_VERSION=$(git tag -l --points-at HEAD | tr -d 'v')
ASSETS=${ASSETS:-/tmp/assets}


echo "Building binaries of grafana ${GRAFANA_VERSION} ($commit-$buildstamp) for $@"

for ARM in "$@"
do
  case "$ARM" in
    armv6)
      PHJSV="v2.1.1-wheezy-jessie-armv6"
      install_phjs
      armv6_install_cross
      ;;
    armv7)
      PHJSV="v2.1.1-wheezy-jessie"
      install_phjs
      armv7_install_cross
      ;;
    arm64)
      PHJSV="v2.1.1-jessie-stretch-arm64"
      install_phjs
      arm64_install_cross
      ;;
    win64)
      install_win64_phjs
      win64_install_cross
      ;;
    *)
      echo >&2 'error: unknown arch:' "$ARM"
      usage >&2
      exit 1
      ;;
  esac
  build_bin
  fix_assets
done
