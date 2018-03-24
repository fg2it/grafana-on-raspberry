#Cross build Grafana master for armv6-v7 wheezy/jessie/stretch
FROM debian:stretch

ARG GRAFANA_VERSION=5.0.0
ARG ASSETS=/tmp/assets
ARG DEPTH=1

ENV LABEL=v${GRAFANA_VERSION} \
    DEPTH=${DEPTH} \
    PATH=/usr/local/go/bin:$PATH \
    GOPATH=/tmp/graf-build \
    NODEVERSION=6.9.2 \
    ASSETS=${ASSETS}

COPY ./build.sh /

RUN chmod 700 /build.sh    && \
    apt-get update         && \
    apt-get install -y        \
        bzip2                 \
        ca-certificates       \
        curl                  \
        git                   \
        binutils              \
        gcc-6-cross-base      \
        libcc1-0              \
        libisl15              \
        libmpc3               \
        libmpfr4           && \ 
    mkdir -p ${ASSETS}/deb    \
             ${ASSETS}/tgz    \
             $GOPATH/src/github.com/grafana    && \
    curl -L https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_amd64.deb \
         -o /tmp/grafana_${GRAFANA_VERSION}_amd64.deb                                                     && \
    dpkg-deb -R /tmp/grafana_${GRAFANA_VERSION}_amd64.deb ${ASSETS}/deb && \
    mv ${ASSETS}/deb/DEBIAN ${ASSETS}/DEBIAN        && \
    curl -L https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-${GRAFANA_VERSION}.linux-x64.tar.gz \
      | tar -xz -C ${ASSETS}/tgz                && \
    cd $GOPATH/src/github.com/grafana          && \
    git clone -b ${LABEL} --depth ${DEPTH} --single-branch https://github.com/grafana/grafana.git && \
    cd $GOPATH/src/github.com/grafana/grafana  && \
    git checkout                               && \
    GOVERSION=$(grep 'ENV GOLANG' scripts/build/Dockerfile | cut -d' ' -f3) && \
    curl -sSL https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz \
      | tar -xz -C /usr/local && \
    go get -v github.com/golang/dep


CMD ["/bin/bash"]
