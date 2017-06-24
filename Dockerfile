FROM debian:jessie-backports

RUN apt-get update \
        && apt-get install -y --no-install-recommends \
                 liblua5.3-0 \
                 libpcre3 \
                 libssl1.0.0 \
        && rm -rf /var/lib/apt/lists/*

ENV HAPROXY_MAJOR 1.7
ENV HAPROXY_VERSION 1.7.6
ENV CONSUL_TEMPLATE_VERSION=0.18.5
ENV HAPROXY_MD5 8f4328cf66137f0dbf6901e065f603cc
ENV UID 1100
ENV GID 1100
ENV USER haproxy
ENV GROUP haproxy
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /
# see http://sources.debian.net/src/haproxy/jessie/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN set -x \
        \
        && buildDeps=' \
                gcc \
                libc6-dev \
                liblua5.3-dev \
                libpcre3-dev \
                libssl-dev \
                make \
                wget \
                vim \
                net-tools \
                supervisor \
                unzip \
                rsyslog \
                curl \
                sysv-rc-conf \
        ' \
        && apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
        && systemctl enable rsyslog \
        \
        && wget -O haproxy.tar.gz "http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" \
        && unzip /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
        && mv /consul-template /usr/local/bin/consul-template \
        && rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
        && echo "$HAPROXY_MD5 *haproxy.tar.gz" | md5sum -c \
        && mkdir -p /usr/src/haproxy \
        && tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
        && rm haproxy.tar.gz \
        \
        && makeOpts=' \
                TARGET=linux2628 \
                USE_LUA=1 LUA_INC=/usr/include/lua5.3 \
                USE_OPENSSL=1 \
                USE_PCRE=1 PCREDIR= \
                USE_ZLIB=1 \
        ' \
        && make -C /usr/src/haproxy -j "$(nproc)" all $makeOpts \
        && make -C /usr/src/haproxy install-bin $makeOpts \
        \
        && mkdir -p /var/lib/haproxy \
        && mkdir -p /run/haproxy \
        && mkdir -p /etc/consul-template \
        && groupadd -g $GID $GROUP \
        && useradd -u $UID -g $GID -m $USER \
        && mkdir -p /etc/haproxy \
        && mkdir -p /haproxy \
        && mkdir -p /etc/consul-template \
        && mkdir -p /applog/consul-template \
        && mkdir -p /applog/supervisor/supervisor \
        && cp -R /usr/src/haproxy/examples/errorfiles /etc/haproxy/errors \
        && rm -rf /usr/src/haproxy \
        \
        && apt-get purge -y --auto-remove gcc libc6-dev liblua5.3-dev libpcre3-dev libssl-dev make 
WORKDIR /etc/consul-template
COPY supervisor-consul-template.conf.bak /etc/supervisor/conf.d/
COPY haproxy.ctmpl.bak /etc/consul-template/
COPY reload.sh /haproxy/
COPY tmpl.json /etc/consul-template/
COPY start.sh /haproxy/
COPY haproxy.cfg /etc/haproxy/
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
