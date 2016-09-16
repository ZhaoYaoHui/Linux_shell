#!/bin/sh
#
# Author: Zhaoyh   -----  zhaoright@gmail.com
# Created Time: 2016-09-03 20:54
# Last Modified Time: 2016-09-03 21:38:36
# FileName: abrt-oops.sh
# chkconfig 35 82 16
# Description: watches system log for oops messages, creates ABRT dump directories for each oops
### BEGIN INIT INFO
# Required-Start: $abrte
# Default-Stop: 0 1 2  6
# Default-Start: 3 5
### END INIT INFO

# source function library
. /etc/init.d/functions

# For debugging
dry_run=false
verbose=false

# We don't have pid files, therefore have to use
# a flag file in /var/lock/subsys to enable GUI service tools
# to figure out our starts
LOCK="/var/lock/subsys/abr-oops"

RETVAL=0

check() {
    [ "`id -u`" = 0 ] || exit 4
}
start() {
    check
    killall abrt-dump-oops 2>/dev/null
    setsid abrt-dump-oops -d /var/spool/sbrt -rwx /var/log/messages </dev/null >/dev/null 2>&1 &
    $dry_run || touch -- "$LOCK"
    return $RETVAL
}

stop() {
    check
    killall abrt-dump-oops
    $dry_run || rm -f -- "$LOCK"
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
    # It is already running?
    if [ -f "$LOCK" ]; then #yes
        $verbose && printf "Running, restarting\n"
        restart
    fi
    ;;
status)
    status abrt-dump-oops
    RETVAL=$?
    ;;
*)
    echo $"Usage: $0 {start|stop|restart|reload|condrestart|force-reload}"
    RETVAL=2
esac

return $RETVAL
