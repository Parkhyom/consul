#!/bin/sh
/usr/local/sbin/haproxy -D -p /run/haproxy.pid -f /etc/haproxy/haproxy.cfg -sf $(cat /run/haproxy.pid) || true
