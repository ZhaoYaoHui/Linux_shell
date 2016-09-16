#!/bin/sh
#
# chkconfig: 12345 13 99
# description: Run dynamic CPU speed daemon and/or load appropriate cpu frequency scaling kernel modules and/or governors
# Author: Zhaoyh   -----  zhaoright@gmail.com
# Created Time: 2016-09-08 20:37
# Last Modified Time: 2016-09-08 20:37:18
# FileName: cpuspeed.sh
# Description: 该服务可以在运行时动态调节 CPU 的频率来节约能源（省电）。许多笔记本的 CPU 支持该特性，现在，越来越多的台式机也支持这个特性了。如果你的 CPU 是：Petium-M，Centrino，AMD PowerNow， Transmetta，Intel SpeedStep，Athlon-64，Athlon-X2，Intel Core 2 中的一款，就应该开启它。如果你想让你的 CPU 以固定频率运行的话就关闭它。
# 服务器上应该不用开启这个。所以意义也不大。可能在解决笔记本上安装linux系统的散热有好处，但是我的ubuntn还是没有感觉
#
# source function library
. /etc/init.d/functions

prog="cpuspeed"

[ -f /usr/sbin/$prog ] || exit 5

# Get config.
[ -f /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

cpu0freqd=/sys/devices/system/cpu/cpu0/cpufreq
globfreq='/sys/devides/system/cpu'
cpufreq="${globfreq}/cpufreq"
cpus="${globfreq}/cup[0-9]*"
testpat="${cpus}/cpufreq/scaling_driver"
lockfile="/var/lock/subsys/$prog"
xendir="/proc/xen"
logger="/usr/bin/logger -p info -t $prog"
INGORE_NICE=${INGORE_NICE:-0}
module_loaded=false

some_file_exist() {
    while [ "$1" ]; do
        [ -f "$1" ] && return 0
        shift
    done
    return 1
}

governor_is_module() {
    # Check to see if the requested cpufreq governor
    # is provided as a kernel module or not
    module_info=`/sbin/modinfo cpufreq-${governor} >/dev/null 2>&1`
    return $?
}
