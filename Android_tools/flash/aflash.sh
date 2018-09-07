#!/bin/bash


declare -A -r IMAGES_MAP=(
    [boot]=boot.img
    [recovery]=recovery.img
    [system]=system.img
    [vendor]=vendor.img
)


function usage()
{
    local p

    echo -e "
usage:
\t$(basename $0) partition1 [partition2:image2] ...
"
    echo "partitions:"
    for p in ${!IMAGES_MAP[@]}; do
        echo -e "\t"${p}":"${IMAGES_MAP[$p]}
    done
    exit 1
}

function show_and_exec()
{
    local rc

    echo -e "\033[01;32m$@\033[00m"
    eval $@
    rc=$?
    if [[ 0 -ne $rc ]]; then
        echo -e "\033[01;31merror: failed to run $@\033[00m"
        exit $rc
    fi
}

function _ifs_CR()
{
    _IFS_BACKUP=$IFS
    IFS="
"
}

function _ifs_r()
{
    IFS=$_IFS_BACKUP
}

function get_path()
{
    eval ${1}=${2}
    if [[ -n "$ANDROID_HOST_OUT" ]]; then
        eval ${1}=${ANDROID_HOST_OUT}/bin/${2}
        if [[ ! -x "$1" ]]; then
            if [[ -n "$ANDROID_HOME" ]]; then
                eval ${1}=${ANDROID_HOME}/platform-tools/${2}
                if [[ ! -x "$1" ]]; then
                    eval ${1}=${2}
                fi
            fi
        fi
    fi
}

declare -A adb_devices
function adb_list_devices()
{
    local output
    local serialno
    local state
    local fingerprint

    #unset adb_devices
    for serialno in ${!adb_devices[@]}; do
        unset adb_devices[$serialno]
    done
    output=$($ADB devices 2>/dev/null)
    _ifs_CR
    for line in $output; do
        if [[ "List of devices attached" == $line ]]; then
            continue
        fi
        serialno=${line%	*}
        state=${line#*	}
        fingerprint=$($ADB -s $serialno shell getprop ro.build.fingerprint)
        adb_devices[${serialno}\(${state},${fingerprint}\)]=${serialno}
    done
    _ifs_r
}

declare -A fastboot_devices
function fastboot_list_devices()
{
    local output
    local serialno
    local state
    local product

    #unset fastboot_devices
    for serialno in ${!fastboot_devices[@]}; do
        unset fastboot_devices[$serialno]
    done
    output=$($FASTBOOT devices 2>/dev/null)
    _ifs_CR
    for line in $output; do
        serialno=${line%	*}
        state=${line#*	}
        product=$($FASTBOOT -s $serialno getvar product 2>&1)
        product=${product#product: }
        product=${product%
Finished*}
        fastboot_devices[${serialno}\(${state},${product}\)]=$state
    done
    _ifs_r
}

function parse_arg()
{
    local imageprefix=${ANDROID_PRODUCT_OUT:-.}
    local _p
    local _i
    local p

    if [ 0 -eq $# ]; then
        usage
    fi
    for p in $@; do
        _p=${p%:*}
        _i=${p#*:}
        if [[ ${#p} -gt ${#_p} ]]; then
            images[$_p]=${imageprefix}/${_i}
        elif [[ -n ${IMAGES_MAP[$p]} ]]; then
            images[$p]=${imageprefix}/${IMAGES_MAP[$p]}
        fi
    done

    if [[ $# > ${#images[@]} ]]; then
        usage
    fi
    for p in ${!images[@]}; do
        if [[ ! -r ${images[$p]} ]]; then
            echo "error: ${images[$p]} is not readable"
            exit 1
        fi
    done
}

function wait_for_device()
{
    while true; do
        fastboot_list_devices
        if [[ -n $serialno ]]; then
            while [[ "fastboot" != ${fastboot_devices[$serialno]} ]]; do
                echo "wait for bootloader..."
                sleep 3
                fastboot_list_devices
            done
        else
#            if [[ 1 == ${#fastboot_devices[@]} ]]; then
#                serialno=${!fastboot_devices[@]}
#            elif [[ 1 < ${#fastboot_devices[@]} ]]; then
                select serialno in ${!fastboot_devices[@]}; do
                    break
                done
#            fi
        fi
        if [[ -n $serialno ]]; then
            serialno=${serialno%(*}
            export ANDROID_SERIAL=$serialno
            break
        fi

        unset serialno
        adb_list_devices
#        if [[ 1 == ${#adb_devices[@]} ]]; then
#            serialno=${!adb_devices[@]}
#        elif [[ 1 < ${#adb_devices[@]} ]]; then
            select serialno in ${!adb_devices[@]}; do
                break
            done
#        fi
        if [[ -n $serialno ]]; then
            serialno=${serialno%(*}
            show_and_exec $ADB -s $serialno reboot bootloader
            continue
        fi
        echo "wait for device..."
        sleep 3
    done
}

function flash_all()
{
    local p

    for p in ${!images[@]}; do
        show_and_exec $FASTBOOT -s $serialno flash $p ${images[$p]}
    done
    show_and_exec $FASTBOOT -s $serialno reboot
}


## main
get_path ADB adb
get_path FASTBOOT fastboot

# get partitions and images
declare -A images
parse_arg $@

# wait device
serialno=
wait_for_device

# flash images
flash_all

