#!/bin/sh
#
# Author: Zhaoyh   -----  zhaoright@gmail.com
# Created Time: 2016-09-03 21:49
# Last Modified Time: 2016-09-03 22:53:28
# FileName: acpid.sh
# chkconfig 345 26 74
# Description: Listen and dispatch ACPI events from the kernel
# 电源的开关等检测管理，意义不大 
# processname: acpid
### BEGIN INIT INOF
# Provides: acpid
# Required-Start: $syslog $local_fs
# Required-Stop: $syslog $local_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description:start and stop acpid
#通过挂起不必要的设备、降低CPU的频率或者其它方法，可以减少能量的消耗，达到省电的目的。电源管理实际上是一个系统工程，从应用程序到内核框架，再到设备驱动和硬件设备，都要参与进来，才能达到电源管理的最优化。本文介绍一下ACPId服务的工作原理。ACPId服务是AdvancedConfigurationandPowerInterface缩写，acpid中的d则代表daemon。Acpid是一个用户空间的服务进程，它充当Linux内核与应用程序之间通信的接口，负责将kernel中的电源管理事件转发给应用程序。
#ACPId服务与内核的通信方式：acpid用poll函数挂在/proc/acpi/event文件上。内核在drivers/acpi/event.c中实现了该文件的接口，一旦总线事件列表(acpi_bus_event_list)上有电源管理事件发生，内核就会唤醒挂在/proc/acpi/event上的acpid，acpid再从/proc/acpi/event中读取相应的事
#件。acpid与应用程序的通信方式有两种，
#其一是通过本地socket，其文件名为/var/run/acpid.socket，应用程序只要连接到这个socket上，不用发送任何命令就可以接收到acpid转发的电源管理事件。
#其二是通过配置文件。在acpid收到来自内核的电源管理事件时，根据配置文件中的规则执行指定的命令。
#ACPId服务配置文件在/etc/acpi/events/目录下，
#下面是一个示例:
#event=button/power.*action=/sbin/shutdown-hnow
#ACPId服务事件的格式为：
#device_classbus_idtypedata。device_class和bus_id是字符串，type和data是十六制整数。在配置文件中可以使用通配符，来匹配指定的事件。
### END INIF INFO

# source function library
. /etc/init.d/functions

RETVAL=0

#
# See how we were called.
#

check() {
    # Check that we're a privileged user
    [ "`id -u`" = 0 ] || exit 4

    # Check if acpid is executable
    [ -x /usr/sbin/acpid ] || exit 5
}

start() {
    check
    
    # Check for kernel support
    [ -f /proc/acpi/event ] || exit 1

    # Check if it is already running
    if [ ! -f /var/lock/subsys/acpid ]; then
        echo -n $"Starting acpi daemon:"
        daemon /usr/sbin/acpid
        RETVAL=$?
        [ $RETVAL -eq 0 ] && touch /var/lock/subsys/acpid
        echo
    fi
    return $RETVAL
}
stop() {
    check

    echo -n $"Stopping acpi daemon:"
    killproc /usr/sbin/acpid
    RETVAL=$?
    [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/acpid
    echo
    return $RETVAL
}

restart() {
    stop
    start
}

reload() {
    check
    trap "" SIGHUP
    action $"Reloading acpi daemon:" killall -HUP acpid
    RETVAL=$?
    return $RETVAL
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
status)
    status acpid
    RETVAL=$?
    ;;
force-reload)
    echo "$0: Unimplemented feature."
    RETVAL=3
    ;;
condrestart)
    if [ -f /var/lock/subsys/acpid ];then
        restart
    fi
    ;;
*)
    echo $"Usage: $0 {start|stop|restart|reload|condrestart|force-reload}"
    RETVAL=2
esac

exit $RETVAL
