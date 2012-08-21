#!/bin/sh
# Default acpi script that takes an entry for all actions

lock() { logger "locking"; su sebastian -c 'DISPLAY=:0 i3lock -c 000000'; }

suspend() {
	/etc/pm/sleep.d/00pidgin thaw
    lock
    echo mem > /sys/power/state
    sleep 1
    hdparm -B 255 /dev/sda
	/etc/pm/sleep.d/00pidgin resume
}

minspeed=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq`
maxspeed=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`
setspeed="/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"

set $*

case "$1" in
    button/power)
        case "$2" in
            PBTN|PWRF)
                logger "PowerButton pressed: $2"
                suspend
                #poweroff
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    button/sleep)
        case "$2" in
            SLPB|SBTN)
                suspend
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    button/prog1)
        case "$2" in
            PROG1)
                suspend
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    button/screenlock)
        case "$2" in
            SCRNLCK)
                lock
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    ac_adapter)
        case "$2" in
            AC|ACAD|ADP0)
                case "$4" in
                    00000000)
                        echo -n $minspeed >$setspeed
                        #/etc/laptop-mode/laptop-mode start
                        ;;
                    00000001)
                        echo -n $maxspeed >$setspeed
                        #/etc/laptop-mode/laptop-mode stop
                        ;;
                esac
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    battery)
        case "$2" in
            BAT0)
                case "$4" in
                    00000000)
                        logger 'Battery online'
                        ;;
                    00000001)
                        logger 'Battery offline'
                        ;;
                esac
                ;;
            CPU0)
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/lid)
        case "$3" in
            close)
                suspend
                ;;
            open)
                ;;
            *)
                logger "ACPI action undefined: $3"
                ;;
    esac
    ;;
    *)
        logger "ACPI group/action undefined: $1 / $2"
        ;;
esac

# vim:set ts=4 sw=4 ft=sh et:
