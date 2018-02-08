#Cross build Grafana master for armv6-v7 wheezy/jessie
FROM debian:jessie

ARG LABEL=master
ARG DEPTH=1
ARG COMMIT

ENV LABEL=${LABEL} \
    DEPTH=${DEPTH} \
    PATH=/usr/local/go/bin:$PATH \
    GOPATH=/tmp/graf-build \
    NODEVERSION=6.9.2

COPY ./build.sh /

RUN chmod 700 /build.sh  && \
    apt-get update       && \
    apt-get install -y      \
        apt-transport-https \
        binutils            \
        bzip2               \
        ca-certificates     \
        curl                \
        dh-autoreconf       \
        g++                 \
        gcc                 \
        git                 \
        libc-dev            \
        libfontconfig1      \
        make                \
        python              \
        ruby                \
        ruby-dev            \
        xz-utils        &&  \
    gem install --no-ri --no-rdoc fpm          && \
    curl -sSL https://nodejs.org/dist/v${NODEVERSION}/node-v${NODEVERSION}-linux-x64.tar.xz    \
      | tar -xJ --strip-components=1 -C /usr/local && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb [arch=amd64] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install yarn     && \
    mkdir -p $GOPATH/src/github.com/grafana    && \
    cd $GOPATH/src/github.com/grafana          && \
    git clone -b ${LABEL} --depth ${DEPTH} --single-branch https://github.com/grafana/grafana.git && \
    cd $GOPATH/src/github.com/grafana/grafana  && \
    git checkout ${COMMIT}                     && \
    yarn install --pure-lockfile               && \
    GOVERSION=$(grep 'ENV GOLANG' scripts/build/Dockerfile | cut -d' ' -f3) && \
    curl -sSL https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz \
      | tar -xz -C /usr/local && \
    go run build.go setup


CMD ["/bin/bash"]
