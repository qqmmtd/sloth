#!/bin/bash

###############################
# LOG_TEMP=$(mktemp)
# source android_style_log.bash
###############################

##
LOG_LEVEL=4
LOG_LEVEL_MAX=4
declare -A TO_LEVEL=([E]=1 [W]=2 [I]=3 [D]=4)
if [[ "$LOG_LEVEL" > "$LOG_LEVEL_MAX" ]]; then
    LOG_VERBOSE=true
else
    LOG_VERBOSE=false
fi

##
if [[ -z $LOG_TEMP ]]; then
    echo "LOG_TEMP is NULL, please set it before source this script for log out!"
    read -p 'LOG_TEMP: ' line
    LOG_TEMP="$line"
fi

##
cat << EOF > $LOG_TEMP
================================================================================

AUTO LOG OUT BY:
    android_style_log.bash

START TIME:
    $(date)

CALLER:
    $0

================================================================================

EOF

##
_log ()
{
    local msg

    if [[ "${TO_LEVEL[$1]}" -le "$LOG_LEVEL" ]]; then
        if $LOG_VERBOSE; then
            msg="$1/[${FUNCNAME[@]}][${BASH_LINENO[@]}]: $3"
            echo -e "\033[0;${2}m${msg}\033[0m"
            echo "$msg" >> $LOG_TEMP
        else
            printf "\033[0;${2}m%s/%s(%4d): %s\033[0m\n" "$1" "${FUNCNAME[2]}" "${BASH_LINENO[1]}" "$3"
            printf "%s/%s(%4d): %s\n" "$1" "${FUNCNAME[2]}" "${BASH_LINENO[1]}" "$3" >> $LOG_TEMP
        fi
    fi
}

##
LOGE ()
{
    _log 'E' '31' "$@"
}
LOGW ()
{
    _log 'W' '33' "$@"
}
LOGI ()
{
    _log 'I' '0' "$@"
}
LOGD ()
{
    _log 'D' '32' "$@"
}

