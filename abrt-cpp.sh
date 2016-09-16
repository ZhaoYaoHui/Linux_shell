#!/bin/sh
#
# Author: Zhaoyh   -----  zhaoright@gmail.com
# Created Time: 2016-09-03 18:20
# Last Modified Time: 2016-09-03 19:32:22
# FileName: abrt-cpp.sh
# chkconfig 35 82 16
# Description: Install coredump handler which saves segfault date
# 这个是一个内核转储的服务，具体不是很了解。
# Provides: abrt-ccpp
# Required-Start: $abrtd
# Default-Stop: 0 1 2 6
# Default-Start: 3 5
# Short_Description: Installs coredump handler which saves segfault data
# source function library
###End INIT INFO
# Source function library.
. /etc/init.d/functions

LOCK="/var/lock/subsys/abrt-ccpp"
INSTALL_HOOK="/usr/sbin/abrt-install-ccpp-hook"

RETVAL=0

check() {
    # Check that we're a privileged user
    [ "`id -u`" = 0 ] || exit 4
}

start() {
    check

    $INSTALL_HOOK install
    RETVAL=$?
    [ $RETVAL -eq 0 ] && touch -- "$LOCK"
    return $RETVAL
}
stop() {
   check

   $INSTALL_HOOK uninstall
   RETVAL=$?
   [ $RETVAL -eq 0 ] && rm -f -- "$LOCK"
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
    $INSTALL_HOOK is-installed && restart
    ;;
status)
    $INSTALL_HOOK is-installed && RETVAL=0 || RETVAL=3
    ;;
*)
    echo $"Usage: $0 {start|stop|status|restart|reload|condrestart|force-reload}"
    RETVAL=2
esac

exit $RETVAL
