#!/bin/sh

set -e

SUPERVISOR_HTTP=${SUPERVISOR_HTTP:-*}
SUPERVISOR_CONFIG=${SUEPRVISOR_CONFG:-/etc/supervisor/conf.d}
sed -i "s/\/var\/log/\/applog/g" /etc/supervisor/supervisord.conf 
sed -e "s/127.0.0.1/${SUPERVISOR_HTTP}/g" /etc/supervisor/conf.d/supervisor-consul-template.conf.bak > ${SUPERVISOR_CONFIG}/supervisor-consul-template.conf
# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
        set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
        # if the user wants "haproxy", let's use "haproxy-systemd-wrapper" instead so we can have proper reloadability implemented by upstream
        shift # "haproxy"
        set -- "$(which haproxy-systemd-wrapper)" -p /run/haproxy.pid "$@"
        #set -- "$(which haproxy)" -p /run/haproxy.pid "$@"
fi
exec "$@" &
supervisord -n
