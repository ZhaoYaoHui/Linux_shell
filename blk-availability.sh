#!/bin/sh
#
# chkconfig: 12345 25 75
# description: Controls availability of block devices
# Author: Zhaoyh   -----  zhaoright@gmail.com
# Created Time: 2016-09-08 20:21
# Last Modified Time: 2016-09-08 20:21
# FileName: blk-availability.sh
# Description: LVM2 的一个块设备管理服务，所以如果我们没有使用lvm完全可以关闭这个服务
# 在C5中没有这个服务，是C6的服务
# 这个脚本好像意义不大？感觉不是很完整的，是这个功能还没有完善？

### BEGIN INIT INFO
# Provides:blk-availability
# Required-Start:
# Required-Stop:
# Default-Start: 1 2 3 4 5
# Default-Stop: 0 6
### END INIT INFO

# source function library
. /etc/init.d/functions
sbindir=/sbin
script=blkdeactivate
options="-u -l wholevg"

LOCK_FILE="/var/lock/subsys/blk-availability"

RETVAL=0

case "$1" in
    start)
        touch $LOCK_FILE
        ;;
    stop)
        action "Stopping block device availability:" $sbindir/$script $options
        rm -f $LOCK_FILE
        ;;
    status)
        ;;
    *)
        echo $"Usage: $0 {start|stop|status}"
        ;;
esac
