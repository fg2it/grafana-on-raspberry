FROM resin/armv7hf-debian:jessie

ARG REPO_TAG
ARG PKG_NAME

RUN apt-get update && \
    apt-get -y --no-install-recommends install libfontconfig curl ca-certificates && \
    apt-get clean && \
    curl -o /tmp/grafana.deb -L https://github.com/fg2it/grafana-on-raspberry/releases/download/${REPO_TAG}/grafana_${PKG_NAME}_armhf.deb && \
    curl -o /usr/sbin/gosu -fsSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-$(dpkg --print-architecture)" && \
    chmod +x /usr/sbin/gosu && \
    apt-get remove -y curl  && \
    apt-get autoremove -y   && \
    rm -rf /var/lib/apt/lists/* && \
    dpkg -i /tmp/grafana.deb || true && \
    rm /tmp/grafana.deb


VOLUME ["/var/lib/grafana", "/var/log/grafana", "/etc/grafana"]

EXPOSE 3000

COPY ./run.sh /run.sh

ENTRYPOINT ["/run.sh"]
