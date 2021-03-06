#!/bin/sh
#
# chkconfig: 345 95 5
# description: Runs commands scheduled by the "at" command at the time \
#   specified when "at" was run, and runs batch commands when the load \
#   average is low enough.
# Author: Zhaoyh   -----  zhaoright@gmail.com
# Created Time: 2016-09-08 16:21
# Last Modified Time: 2016-09-08 16:21
# FileName: atd.sh
# Description: 同crond，也是第一个定时任务，但这atd是一个一次性的定时任务，利用at命令来执行. 
#

### BEGIN INIT INOF
# provides: atd at batch
# Required-Start: $local_fs
# Required-Stop: $local_fs
# Default-Start: 345
# Default-Stop: 95
### END INIT INFO

# source function library
. /etc/init.d/functions

exec=/usr/sbin/atd
prog="atd"
config=/etc/sysconfig/atd

[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

lockfile=/var/lock/subsys/$prog

start() {
    [ -x $exec ] && exit 5
    [ -f $config ] && exit 6
    echo -n $"Starting $prog: "
    daemon $exec $OPTS
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && touch $lockfile
}

stop() {
    echo -n $"Stopping $prog: "
    if [ -n "`pidfileofproc`" ]; then
        killproc $proc
        RETVAL=3
    else
        failure $"Stopping $prog"
    fi
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && rm -f $lockfile
}

restart() {
    stop
    start
}

reload() {
    restart
}

force_reload() {
    restart
}

rh_status() {
    # run checks to determine if the service is running or use generic status
    status $prog
}

rh_status_q() {
    rh_status > /dev/null 2>&1
}

case "$1" in
    start)
        rh_status_q && exit 0
        start
        ;;
    stop)
        rh_status_q || exit 0
        stop
        ;;
    restart)
        restart
        ;;
    reload)
        rh_status_q || exit 7
        reload
        ;;
    force_reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        re_status_q || exit 0
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
esac

exit $?
