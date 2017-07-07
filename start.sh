#!/bin/sh

set -e
#required vars
CONSUL_ROOT=/consul
CONFIG_FILE=${HAPROXY_ROOT}/haproxy.cfg
TEMPLATE=/etc/consul-template/tmpl.json

HAPROXY_STATUS_PORT=${HAPROXY_STATUS_PORT:-9000}
HAPROXY_PROXY_PORT=${HAPROXY_PROXY_PORT:-80}
HAPROXY_DOMAIN=${HAPROXY_DOMAIN:-rongyi.com}
CONSUL_SERVER=${CONSUL_SERVER:-127.0.0.1}
CONSUL_PORT=${CONSUL_PORT:-8500}
LOG_LEVEL=${LOG_LEVEL:-debug}

#start haproxy
#systemctl start haproxy 
#/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid
#/usr/sbin/haproxy -D -p /var/run/haproxy.pid  -f /etc/haproxy/haproxy.cfg -sf $(cat /var/run/haproxy.pid) || true
#start consul-template as follow
sed -e "s/HAPROXY_PROXY_PORT/${HAPROXY_PROXY_PORT}/g;s/HAPROXY_STATUS_PORT/${HAPROXY_STATUS_PORT}/g" /etc/consul-template/haproxy.ctmpl.bak > /etc/consul-template/haproxy.ctmpl
/usr/local/bin/consul-template -consul $CONSUL_SERVER:$CONSUL_PORT \
    -config $TEMPLATE \
    -wait 2s:10s \
    -log-level "$LOG_LEVEL" > /applog/consul-template/consul-template.log 2>&1 
