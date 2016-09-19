#!/bin/sh
#
# chkconfig: 2345 90 60
# description: Cron is a standard UNIX program that runs user-specified programs at periodic scheduled time.
# Author: Zhaoyh   -----  zhaoright@gmail.com
# Created Time: 2016-09-09 22:27
# Last Modified Time: 2016-09-09 22:27
# FileName: crond.sh
# Description:这个就是定时任务服务，没有什么可以说的。 
#
### BEGIN INIT INFO
# Provides: crond crontab
# Required-Start: $local_fs $syslog
# Required-Stop: $local_fs $syslog
# Default-Start: 2345
# Default-Stop: 90
# short-description: run cron daemon
### END INIT INFO

# source function library
. /etc/init.d/functions

[ -f /etc/sysconfig/crond ] || {
    [ "$1" = "status" ] && exit 4 || exit 6
}

RETVAL=0
prog="crond"
exec=/usr/sbin/crond
lockfile=/var/lock/subsys/crond
config=/etc/sysconfig/crond

[ $UID -eq 0 ] && [ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

start() {
    if [ $UID -ne 0 ] ; then
        echo "User has insufficient privilege."
        exit 4
    fi
    [ -x $exec ] || exit 5
    [ -f $config ] || exit 6
    echo -n $"Starting $prog: "
    daemon $prog $CRONDARGS
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
}

stop() {
    if [ $UID -ne 0 ]; then
}
