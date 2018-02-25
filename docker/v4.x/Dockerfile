ARG RELEASE=jessie
FROM resin/armv7hf-debian:${RELEASE}

ARG REPO_TAG
ARG PKG_NAME
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-url="https://github.com/fg2it/grafana-on-raspberry"
LABEL org.label-schema.vcs-ref=$VCS_REF


RUN apt-get update && \
    apt-get -y --no-install-recommends install libfontconfig curl ca-certificates && \
    apt-get clean && \
    curl -o /tmp/grafana.deb -L https://github.com/fg2it/grafana-on-raspberry/releases/download/${REPO_TAG}/grafana_${PKG_NAME}_armhf.deb && \
    curl -o /usr/sbin/gosu -fsSL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" && \
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
