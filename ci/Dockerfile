#Cross build Grafana master for armv6-v7 wheezy/jessie using node 5.10.1
FROM debian:jessie
MAINTAINER fg2it

ENV PATH=/usr/local/go/bin:$PATH \
    GOPATH=/tmp/graf-build \
    NODEVERSION=5.10.1

RUN apt-get update       && \
    apt-get install -y      \
        binutils            \
        bzip2               \
        ca-certificates     \
        curl                \
        g++                 \
        gcc                 \
        git                 \
        libc-dev            \
        libfontconfig1      \
        make                \
        ruby                \
        ruby-dev            \
        xz-utils        &&  \
    gem install --no-ri --no-rdoc fpm      && \
    curl -sSL https://storage.googleapis.com/golang/go1.7.1.linux-amd64.tar.gz \
      | tar -xz -C /usr/local && \
    curl -sSL https://nodejs.org/dist/v${NODEVERSION}/node-v${NODEVERSION}-linux-x64.tar.xz    \
      | tar -xJ --strip-components=1 -C /usr/local && \
    mkdir -p $GOPATH          && \
    cd $GOPATH                && \
    go get github.com/grafana/grafana  || true && \
    cd $GOPATH/src/github.com/grafana/grafana  && \
    npm install                                && \
    go run build.go setup

COPY ./build.sh /

RUN chmod 700 /build.sh

CMD ["/bin/bash"]
