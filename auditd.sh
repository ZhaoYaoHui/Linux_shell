#!/bin/sh
#
# chkconfig: 2345 11 88
# description: This starts the linux Auditing System Daemon, which collects security related events in a dedicated audit log.
# Author: Zhaoyh   -----  zhaoright@gmail.com
# Created Time: 2016-09-08 18:21
# Last Modified Time: 2016-09-08 18:21
# FileName: auditd.sh
# Description: 
# Linux内核有用日志记录事件的能力，比如记录系统调用和文件访问。然后，管理员可以评审这些日志，确定可能存在的安全裂口，比如失败的登录尝试，或者 用户对系统文件不成功的访问。这种功能称为Linux审计系统，
# (1) 配置审计守护进程。
# (2) 添加审计规则和观察器来收集所需的数据。
# (3) 启动守护进程，它启用了内核中的Linux Auditing System并开始进行日志记录。
# (4) 通过生成审计报表和搜索日志来周期性地分析数据。
# 当安装了 auditd 软件后，运行这个软件将会启动审核守护进程（auditd）。
# 当auditd 运行的时候，审核信息会被发送到一个用户配置日志文件中（默认的文件是 /var/log/audit/audit.log）。
# 如果 auditd 没有运行，审核信息会被发送到 syslog。
# 这是通过默认的设置来把信息放入 /var/log/messages。
# 如果审核子系统没有被启用，没有审核信息会被产生。
# 这些审核信息包括了 SELinux AVC 信息。以前，AVC信息会被发送到 syslog，但现在会被审核守护进程发送到审核日志文件中。
# 要完全在内核中禁用审核，在启动的时候使用 audit=0 参数。您还需要使用 chkconfig auditd off 2345 来关闭 auditd。
# 您可以在运行时使用 auditctl -e 0 来在内核中关闭审核。审核守护进程（auditd）从内核的audit netlink接口获取审核事件数据。auditd 的配置会不尽相同，如输出文件配置和日志文件磁盘使用参数可以在 /etc/auditd.conf 文件中配置。请注意，如果您设置您的系统来进行CAPP风格的
# 审核，您必须设置一个专用的磁盘分区来只供 audit 守护进程使用。这个分区应该挂载在 /var/log/audit。系统管理员还可以使用 auditctl 工具程序来修改auditd守护进程运行时的审核参数、syscall 规则和文件系统的查看。它包括了一个 CAPP 配置样本，您可以把它拷贝到
# /etc/audit.rules 来使它起作用。审核日志数据可以通过 ausearch 工具程序来查看和搜索。
# processname: /sbin/auditd
# config:/etc/sysconfig/auditd
# config:/etc/audit/auditd.conf
# pidfile: /var/run/auditd.pid
# 
# source function library
. /etc/init.d/functions

PATH=/sbin:/bin:/usr/bin:/usr/sbin
prog="auditd"

# Allow anyone to run status  任何人都可以使用status参数查看状态
if [ "$1" = "status" ]; then
    status $prog
    RETVAL=$?
    exit $RETVAL
fi

# Check that we are root ... so non-root users stop here 除了root 能向下执行，其他不能
[ "$EUID" -eq 0 ] || exit 4

# Check config
[ -f "/etc/sysconfig/auditd" ] && . /etc/sysconfig/auditd

RETVAL=0

start() {
    [ -x /sbin/auditd ] || exit 5
    [ -f /etc/audit/auditd.conf ] || exit 6
    echo -n $"Starting $prog: "
    # Localization for auditd is controlled in /etc/sysconfig/auditd
    if [ -z "$AUDITD_LANG" -o "$AUDITD_LANG" = "none" -o "$AUDITD_LANG" = "NONE" ]; then
        unset LANG LC_TIME LC_ALL LC_MESSAGES LC_NUMERIC LC_MONETARY LC_COLLATE
    else
        LANG="$AUDITD_LANG"
        LC_TIME="AUDITD_LANG"
        LC_ALL="AUDITD_LANG"
        LC_MESSAGES="AUDITD_LANG"
        LC_NUMERIC="AUDITD_LANG"
        LC_MONETARY="AUDITD_LANG"
        LC_COLLATE="AUDITD_LANG"
        export LANG LC_TIME LC_ALL LC_MESSAGES LC_NUMERIC LC_MONETARY LC_COLLATE
    fi
    unset HOME MAIL USER USERNAME
    daemon $prog "$EXTRAOPTIONS"
    RETVAL=$?
    echo 
    if [ $RETVAL -eq 0 ]; then
        touch /var/lock/subsys/auditd
        # Prepare the default rules
        if [ x"$USE_AUGENRULES" != "x" ]; then
            if [ `echo $USE_AUGENRULES | tr "NO" "no"` != "no" ]; then
                [ -d /etc/audit/rules.d ]  && /sbin/augenrules
            fi
        fi
        # Load the default rules
        [ -f  /etc/audit/audit.rules ] && /sbin/auditctl -R /etc/audit/audit.rules >/dev/null
    fi
    return $RETVAL
}

stop() {
    echo -n $"Stopping $prog: "
    killproc $prog
    RETVAL=$?
    echo
    rm -f /var/lock/subsys/auditd
    # Remove watches so shutdown works cleanly
    if [ x"$AUDIT_CLEAN_STOP" != "x" ]; then
        if [ `echo $AUDIT_CLEAN_STOP | tr "NO" "no"` != "no" ]; then
            /sbin/auditctl -D >/dev/null
        fi
    fi
    if [ x"$AUDITD_STOP_DISABLE" != "x" ]; then
        if [ `echo $AUDITD_STOP_DISABLE | tr "NO" "no"` != "no" ]; then
            /sbin/auditctl -e 0 >/dev/null
        fi
    fi
    return $RETVAL
}

reload() {
    [ -f /etc/audit/auditd.conf ] || exit 6
    echo -n $"Reloading configuration: "
    killproc $prog -HUP
    RETVAL=$?
    echo
    return $RETVAL
}

rotata() {
    echo -n $"Rotating logs: "
    killproc $prog -USR1
    RETVAL=$?
    echo
    return $RETVAL
}

resume() {
    echo -n $"Resuming logging: "
    killproc $prog -USR2
    RETVAL=$?
    echo
    return $RETVAL
}

restart() {
    [ -f /etc/audit/auditd.conf ] || exit 6
    stop
    start
}

condrestart() {
    [ -e /var/lock/subsys/auditd ] && restart
    return 0
}

# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    reload|force-reload)
        reload
        ;;
    rotate)
        rotate
        ;;
    resume)
        resume
        ;;
    condrestart|try-restart)
        condrestart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|rotate|resume}"
        RETVAL=3
esac

exit $RETVAL

