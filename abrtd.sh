#!/bin/sh
#
# Author: Zhaoyh   -----  zhaoright@gmail.com
# Created Time: 2016-09-03 19:36
# Last Modified Time: 2016-09-03 20:50:16
# FileName: abrtd.sh
# chkconfig 35 82 16
# Description:Saves segfault data, kernel oopses, fatal exceptions 
# 保存段数据、核心、致命的异常数据？这个服务还是不明白
# processname: abrtd
# pidfile: /var/run/abrtd.pid
### BEGIN INIT INFO
# Provides: abrt
# Required-Start: $syslog $local_fs messagebus
# Required-Stop: $syslog $local_fs
# Default-Stop: 0 1 2 6
# Default-Start: 3 5
### END INIT INFO

# source function library
. /etc/init.d/functions
ABRT_BIN="/usr/sbin/abrtd"
LOCK="/var/lock/subsys/abrtd"
RETVAL=0

#
# Set these variables if you behind proxy
#
#export http_proxy=
#export https_proxy=

check() {
    # Check that we're a privileged user
    [ "`id -u`" = 0 ] || exit 4
    # Check if abrt is executable
    test -x "$ABRT_BIN" || exit 5
}

start() {
    check

    # Check if it is already running
    if [ ! -f "$LOCK" ]; then
        echo -n $"Starting abrt daemon:"
        daemon "$ABRT_BIN"
        RETVAL=$?
        [ $RETVAL -eq 0 ] && touch $LOCK
        echo
    fi
    return $RETVAL
}

stop() {
    check

    echo -n $"Stopping abrt daemon:"
    killproc "$ABRT_BIN:"
    RETVAL=$?
    [ $RETVAL -eq 0 ] && rm -f "$LOCK"
    echo
    return $RETVAL
}

restart() {
    stop
    start
}

reload() {
    restart
}

case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
reload)
    reload
    ;;
restart)
    restart
    ;;
force-reload)
    echo "$0: Unimplemented feature."
    RETVAL=3
    ;;
condrestart)
    if [ -f "$LOCK" ] ;then
        restart
    fi
    ;;
status)
    status abrtd
    RETVAL=$?
    ;;
*)
    echo $"Usage: $0 {start|stop|status|restart|condrestart|reload|force-reloca}"
    RETVAL=2
esac

exit $RETVAL
