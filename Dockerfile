FROM alpine:3.16
ARG BUILD_DATE
LABEL	maintainer="sevenrats" \
		build-date=$BUILD_DATE \
		name="Namecoin-Core" \
		description="Namecoin-Core with JSON-RPC enabled"

ENV NAMECOIN_DBCACHE 400
ENV CORE_USER namecoin
ENV CORE_PASSWORD namecoinz
ENV CORE_HOME /home/$CORE_USER
ENV LC_ALL C

RUN  \
mkdir -p /data/namecoin-core $CORE_HOME && \
    ln -sf /data/namecoin-core $CORE_HOME/.namecoin && \
    adduser -D $CORE_USER && \
    apk add --no-cache namecoin namecoin-cli bash catatonit procps && \
    apk add --no-cache --virtual .build-deps git && \
    chown -R ${CORE_USER} /data && \
    git clone --depth 1 https://github.com/sevenrats/bash-signal-proxy.git && \
    mv bash-signal-proxy/signalproxy.sh / && \
    apk del .build-deps && \
    rm -rf \
        bash-signal-proxy \
        /tmp/* \
        /root/.cache


USER $CORE_USER
COPY root /

ENV NMCCORE_CONF "namecoin-core/namecoin.conf"
ENV CONFS $NMCCORE_CONF
ENV LC_ALL C

# TODO : pull peers from git repo and template them into namecoin.conf at build-time

EXPOSE 8334


CMD ["catatonit", "/entrypoint.sh"]
