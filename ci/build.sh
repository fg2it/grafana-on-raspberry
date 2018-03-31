#!/bin/bash

set -x

usage() {
  base="$(basename "$0")"
  cat <<EOUSAGE
usage: $base <arch>
Build grafana binaries (armv6, armv7 or arm64 on linux, osx64 and win64) and prepare packaging reusing offical assets
Available arch:
  $base armv6
  $base armv7
  $base arm64
  $base osx64
  $base win64
EOUSAGE
}

arm_install_phjs() {
  PHJSURL="https://github.com/fg2it/phantomjs-on-raspberry/releases/download/${PHJSV}"
  PHJS=/tmp/${TARGET}/phantomjs
  mkdir -p /tmp/${TARGET}
  if [ ! -f ${PHJS} ]; then
    curl -L ${PHJSURL}/phantomjs -o ${PHJS}
    chmod a+x ${PHJS}
  fi
  
}

osx64_install_phjs() {
  PHJSURL="https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-macosx.zip"
  PHJS=/tmp/${TARGET}/phantomjs
  mkdir -p /tmp/${TARGET}
  if [ ! -f ${PHJS} ]; then
    curl -L ${PHJSURL} -o /tmp/${TARGET}/phantomjs-2.1.1-macosx.zip
    cd /tmp/${TARGET}
    unzip phantomjs-2.1.1-macosx.zip
    mv /tmp/${TARGET}/phantomjs-2.1.1-macosx/bin/phantomjs ${PHJS}
  fi
}

win64_install_phjs() {
  PHJSURL="https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-windows.zip"
  PHJS=/tmp/${TARGET}/phantomjs.exe
  mkdir -p /tmp/${TARGET}
  if [ ! -f ${PHJS} ]; then
    curl -L ${PHJSURL} -o /tmp/${TARGET}/phantomjs-2.1.1-windows.zip
    cd /tmp/${TARGET}
    unzip phantomjs-2.1.1-windows.zip
    mv /tmp/${TARGET}/phantomjs-2.1.1-windows/bin/phantomjs.exe ${PHJS}
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

osx64_install_cross() {
  apt-get install -y clang llvm-dev patch libxml2-dev xz-utils make
  OSX_SDK_PATH=https://s3.dockerproject.org/darwin/v2/MacOSX10.11.sdk.tar.xz
  cd /tmp
  curl -LO ${OSX_SDK_PATH}
  git clone https://github.com/tpoechtrager/osxcross.git
  mv MacOSX10.11.sdk.tar.xz /tmp/osxcross/tarballs/
  UNATTENDED=yes OSX_VERSION_MIN=10.6 /tmp/osxcross/build.sh
  CC=/tmp/osxcross/target/bin/o64-clang
}
win64_install_cross() {
  apt-get install -y gcc-mingw-w64
  CC=x86_64-w64-mingw32-gcc-posix
}

build_bin() {
  cd $GOPATH/src/github.com/grafana/grafana
  PREF="CGO_ENABLED=1 CC=$CC "
  if [ "$TARGET" == "arm64" ]; then
    PREF+="GOARCH=${TARGET}"
  elif [ "$TARGET" == "win64" ]; then
    #windows 7
    CGO_NTDEF="-D_WIN32_WINNT=0x0601"
    PREF+="GOOS=windows GOARCH=amd64 CGO_CFLAGS=$CGO_NTDEF"
  elif [ "$TARGET" == "osx64" ]; then
    PREF+="GOOS=darwin GOARCH=amd64"
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
  EXE=''
  if [ "$TARGET" == "win64" ]; then
    EXE='.exe'
  elif [[ "$TARGET" == *arm* ]]; then
    cp ./bin/grafana-server ${ASSETS}/deb/usr/sbin/grafana-server
    cp ./bin/grafana-cli ${ASSETS}/deb/usr/sbin/
    cp $PHJS ${ASSETS}/deb/usr/share/grafana/tools/phantomjs/
  fi

  tgzdir=${ASSETS}/tgz/grafana-${GRAFANA_VERSION}
  rm ${tgzdir}/bin/*
  for file in 'grafana-server' 'grafana-cli'
  do
    destfile=${tgzdir}/bin/${file}${EXE}
    cp ./bin/${file} $destfile
    md5sum ${destfile} | cut -d ' ' -f1 > ${destfile}.md5
  done

  cp $PHJS ${tgzdir}/tools/phantomjs/

  mkdir -p ${ASSETS}/${TARGET}
}

cd $GOPATH/src/github.com/grafana/grafana
commit=$(git rev-parse --short HEAD)
buildstamp=$(git show -s --format=%ct)
GRAFANA_VERSION=$(git tag -l --points-at HEAD | tr -d 'v')
ASSETS=${ASSETS:-/tmp/assets}


echo "Building binaries of grafana ${GRAFANA_VERSION} ($commit-$buildstamp) for $@"

for TARGET in "$@"
do
  case "$TARGET" in
    armv6)
      PHJSV="v2.1.1-wheezy-jessie-armv6"
      arm_install_phjs
      armv6_install_cross
      ;;
    armv7)
      PHJSV="v2.1.1-wheezy-jessie"
      arm_install_phjs
      armv7_install_cross
      ;;
    arm64)
      PHJSV="v2.1.1-jessie-stretch-arm64"
      arm_install_phjs
      arm64_install_cross
      ;;
    win64)
      win64_install_phjs
      win64_install_cross
      ;;
    osx64)
      osx64_install_phjs
      osx64_install_cross
      ;;     
    *)
      echo >&2 'error: unknown arch:' "$TARGET"
      usage >&2
      exit 1
      ;;
  esac
  build_bin
  fix_assets
done
