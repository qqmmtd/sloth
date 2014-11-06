#!/bin/bash

WEBHOST='https://172.16.12.62/teleweb'

TMPDIR='/tmp/tmp.teleweb'

function fetch()
{
    if [[ $# == 2 ]]; then
        wget --no-check-certificate --quiet --continue $1 -O $2
    fi
}

function download()
{
    mkdir -p ${TMPDIR}/${2}
    for item in $3; do
        if [[ $item != */ ]]; then
            echo ${1}/${2}${item}
            fetch ${1}/${2}${item} ${TMPDIR}/${2}${item}
        fi
    done
}

function choose()
{
    local rc
    local link=${1}/${2}
    local items
    local item
    local formated

    formated=$(echo "$(fetch $link -)" | awk '
BEGIN {
    RS="[\r\n]"
    FS="[\" ]*";
}

/\.\.\// {
    printf("\n../\n\n\n");
}

/<a href=/ && !/Index of/ {
    printf("\n%s\n%s %s\n%s\n", $3, $5, $6, $7);
}
')

    items=$(echo "$formated" | sed -n 2~4p)
    item=$(echo "$formated" | zenity --list --radiolist \
                                     --text="Index of /$2" \
                                     --width=600 --height=800 \
                                     --column '' --column 'Directory' --column 'Time' --column 'Size')
    rc=$?
    if [[ $rc == 0 && $item != */ ]]; then
        download $1 $2 "$items" \
                | zenity --progress  \
                         --text="Downloading /${2}*" \
                         --pulsate --auto-close \
                         --width=450
        if [[ $? == 0 ]]; then
            return 2
        fi
    else
        if [[ $item != /* ]]; then
            path=${2}${item}
        fi
        path=${path#/}
    fi
    echo $path

    return $rc
}

# Main
rc=0
path=

while [[ $rc == 0 ]]; do
    choose $WEBHOST $path
    rc=$?    
done

if [[ $rc == 2 ]]; then
    if [[ -f ${TMPDIR}/${path}/8Build_Info.txt || -f ${TMPDIR}/${path}/8build_info.txt ]]; then
        cat > ${TMPDIR}/${path}/flashall.sh << MEOF
#!/bin/bash

# Debug
ECHO='echo'

# Set tools here
ADB='adb'
FASTBOOT='fastboot'

# Define functions
function do_flash()
{
    \$ECHO \$FASTBOOT -i 0x1bbb flash \$1 \$2
}

function do_erase()
{
    \$ECHO \$FASTBOOT -i 0x1bbb erase \$1
}

function do_format()
{
    \$ECHO \$FASTBOOT -i 0x1bbb format \$1
}

function do_unzip()
{
    \$ECHO unzip \$1
}

function do_nothing()
{
    echo "do nothing: \$@"
}

function usage()
{
    cat << UEOF
usage: \$0 [-h] [-p] [-s DIR]
    -h show help
    -p flash partition table
    -s set perso directory
UEOF
}

# Main
# default value
flashpt=false
persodir=

# get options
while getopts 'hps:' opt; do
    case \$opt in
    h)
        usage
        exit
        ;;
    p)
        flashpt=true
        ;;
    s)
        persodir=\$OPTARG
        ;;
    esac
done
shift \$((\$OPTIND-1))

# show value
echo
echo flashpt=\$flashpt
echo persodir=\$persodir
echo

# reboot into bootloader
\$ECHO \$ADB reboot bootloader
echo

# show partitions detail
awk 'BEGIN { FS = "[\" ]"; } /<program/ && !/GPT/ { printf("pname[%s] %s[%s] %s[%s] %s[%s]\n", \$14, \$31, \$32, \$16, \$17, \$10, \$11); }' P*.mbn
echo

# flash partition table
if \$flashpt; then
    # confirm again
    read -p 'flash partition table? [Y|y] ' ans;
    case \$ans in
    [Yy])
        # gen gpt_both0.bin
        cat O*.mbn G*.mbn > gpt_both0.bin

        do_flash partition gpt_both0.bin
        echo
        ;;
    esac
fi

# flash msimage (sbl1, tz, rpm, aboot) firstly
for img in *.mbn; do
    case \$img in
    C*)
        do_flash sbl1 \$img
        ;;
    T*)
        do_flash tz \$img
        ;;
    W*)
        do_flash rpm \$img
        ;;
    L*)
        do_flash aboot \$img
        ;;
    esac
done
echo

# erase partitions
for pn in \$(sed -n '/GPT/d;/<zeroout/{s/^.*label="//;s/".*\$//p}' P*.mbn); do
    do_erase \$pn
done
echo

# flash main images
for img in \$PWD/*.{mbn,zip}; do
    base=\$(basename \$img)
    case \$base in
    N*)
        do_flash modem \$img
        ;;
    W*)
        #do_flash rpm \$img
        do_flash rpmbk \$img
        ;;
    C*)
        #do_flash sbl1 \$img
        do_flash sbl1bk \$img
        ;;
    T*)
        #do_flash tz \$img
        do_flash tzbk \$img
        ;;
    D*)
        do_flash sdi \$img
        ;;
    L*)
        #do_flash aboot \$img
        do_flash abootbk \$img
        ;;
    F*)
        do_flash tctpersist \$img
        ;;
    J*)
        do_flash persist \$img
        ;;
    B*)
        do_flash boot \$img
        ;;
    Y*.mbn)
        do_flash system \$img
        ;;
    Y*.zip)
        do_unzip \$img
        do_flash system \${img/zip/mbn.raw}
        ;;
    I*)
        do_format cache
        ;;
    R*)
        do_flash recovery \$img
        ;;
    esac
done
echo

# flash perso
if [[ -d \$persodir ]]; then
    for img in \$persodir/*.{mbn,zip}; do
        base=\$(basename \$img)
        case \$base in
        s*)
            do_flash fsg \$img
            ;;
        e*)
            do_flash splash \$img
            ;;
        u*)
            do_format userdata
            ;;
        m*.mbn)
            do_flash custpack \$img
            ;;
        m*.zip)
            do_unzip \$img
            tmp=\$(echo \$base | tr 'a-z' 'A-Z')
            do_flash custpack \$(dirname \$img)/\${tmp/MBN.ZIP/mbn.raw}
            ;;
        x*)
            do_nothing \$img
            ;;
        esac
    done
else
    for img in \$PWD/*.{mbn,zip}; do
        base=\$(basename \$img)
        case \$base in
        S*)
            do_flash fsg \$img
            ;;
        E*)
            do_flash splash \$img
            ;;
        U*)
            do_format userdata
            ;;
        M*.mbn)
            do_flash custpack \$img
            ;;
        M*.zip)
            do_unzip \$img
            do_flash custpack \${img/zip/mbn.raw}
            ;;
        x*)
            do_nothing \$img
            ;;
        esac
    done
fi
echo

# reboot
\$ECHO \$FASTBOOT -i 0x1bbb reboot
MEOF
        chmod +x ${TMPDIR}/${path}/flashall.sh
        cat > ${TMPDIR}/${path}/md5check.sh << CEOF
#!/bin/bash

sed -i '/txt$/d;s:[^ ]*/::' 8*.txt
md5sum -c 8*.txt
CEOF
        chmod +x ${TMPDIR}/${path}/md5check.sh
    else
        cat > ${TMPDIR}/${path}/flashperso.sh << PEOF
#!/bin/bash

PEOF
        chmod +x ${TMPDIR}/${path}/flashperso.sh
    fi
    nautilus ${TMPDIR}/${path}
fi
