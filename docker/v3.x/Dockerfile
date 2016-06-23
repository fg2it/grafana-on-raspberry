FROM resin/armv7hf-debian:jessie

ARG GRAFANA_VERSION
ARG PKG_NAME

RUN apt-get update && \
    apt-get -y --no-install-recommends install libfontconfig curl ca-certificates libicu52 libjpeg62-turbo libpng12-0 && \
    curl -L https://github.com/fg2it/grafana-on-raspberry/releases/download/v${GRAFANA_VERSION}-jessie/grafana_${PKG_NAME}_armhf.deb > /tmp/grafana.deb && \
    curl -o /usr/sbin/gosu -fsSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-$(dpkg --print-architecture)" && \
    chmod +x /usr/sbin/gosu && \
    apt-get remove -y curl  && \
    apt-get autoremove -y   && \
    dpkg -i /tmp/grafana.deb || true && \
    rm /tmp/grafana.deb


VOLUME ["/var/lib/grafana", "/var/lib/grafana/plugins", "/var/log/grafana", "/etc/grafana"]

EXPOSE 3000

COPY ./run.sh /run.sh

ENTRYPOINT ["/run.sh"]
