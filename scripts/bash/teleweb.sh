#!/bin/bash

WEBHOST='https://172.16.12.62/teleweb'

#TMPDIR='/tmp/tmp.teleweb'

CHECKSUMFILES="8checksum.md5 8Build_Info.txt 8build_info.txt"

FLASHTOOL_FASTBOOT=false

FLASHTOOL_TELEWEB=true

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
    local cformated
    local dtof

    #../ v1A11/ 15-Oct-2015 13:35 - v1A13/ 22-Oct-2015 17:07 -
    formated=$(echo "$(fetch $link -)" | awk -v top=$2 '
BEGIN {
    RS="[\r\n]"
    FS="[\" ]*";
}

/\.\.\// {
    if (top != "") {
        printf("\n../\n\n\n");
    }
}

/<a href=/ && !/Index of/ {
    printf("\n%s\n%s %s\n%s\n", $3, $5, $6, $7);
}
')

    items=$(echo "$formated" | sed -n 2~4p)
    item=$(echo "$formated" | zenity --list --radiolist \
                                     --text="Index of /${2}\nAll images will be checked if choose P*.mbn" \
                                     --width=600 --height=400 \
                                     --column '' --column 'Directory' --column 'Time' --column 'Size')
    rc=$?
    if [[ $rc == 0 && $item != */ ]]; then
        if [[ $item == P*.mbn ]]; then
            dtof='TRUE'
        else
            dtof='FALSE'
        fi
        #FALSE 8checksum.md5 22-Oct-2015 16:04 969 TRUE A1A13030BY00.mbn 22-Oct-2015 16:01 164K ...
        cformated=$(echo "$(fetch $link -)" | awk -v dtof=$dtof -v item=$item '
BEGIN {
    RS="[\r\n]"
    FS="[\" ]*";
}

/<a href=/ && !/Index of/ && $3 !~ /.*\// {
    tof = dtof;
    if ($3 == item) {
        tof = "TRUE";
    }
    printf("%s\n%s\n%s %s\n%s\n", tof, $3, $5, $6, $7);
}
')
echo $cformated
        citems=$(echo "$cformated" | zenity --list --checklist \
                                         --text="/${2}" \
                                         --width=600 --height=600 \
                                         --separator=" " \
                                         --column '' --column 'File' --column 'Time' --column 'Size')
        if [[ -z $citems ]]; then
            return 0
        fi

        download $1 $2 "$citems" \
                | zenity --progress  \
                         --text="Downloading /${2}*" \
                         --pulsate --auto-close \
                         --width=450
        if [[ $? == 0 ]]; then
            return 2
        fi
    else
        if [[ $item != /* ]]; then
            if [[ $item == ../ ]]; then
                path="/"${2}
                path=${path%/*/}"/"
            else
                path=${2}${item}
            fi
        fi
        path=${path#/}
    fi
    echo "new" $path

    return $rc
}

function gen_md5check()
{
    for tmp in $CHECKSUMFILES; do
        if [[ -f ${TMPDIR}/$1/$tmp ]]; then
            cat > ${TMPDIR}/$1/md5check.sh << CEOF
#!/bin/bash

sed -i '/txt$/d;s:[^ ]*/::' 8*.{txt,md5}
md5sum -c 8*.{txt,md5}
CEOF
            chmod +x ${TMPDIR}/$1/md5check.sh
            break
        fi
    done
}    

function gen_fastboot_sh()
{
    cat > ${TMPDIR}/$1/fastboot_flashall.sh << MEOF
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
    chmod +x ${TMPDIR}/$1/fastboot_flashall.sh
}

function gen_teleweb_sh()
{
    local projectname

    if [[ -n $1 ]]; then
        projectname=${1%%/*}
    fi

    #TODO
    firehosepath=
    rawprogram=

    cat > ${TMPDIR}/$1/teleweb_flashall.sh << TEOF
#!/bin/bash

FLASHTOOL_TELEWEB_BIN='FlashTool'

for img in *.{mbn,zip}; do
    case \$img in
    C*)
        cp \$img sbl1.mbn
        ;;
    T*)
        cp \$img tz.mbn
        ;;
    W*)
        cp \$img rpm.mbn
        ;;
    L*)
        cp \$img emmc_appsboot.mbn
        ;;
    N*)
        cp \$img NON-HLOS.bin
        ;;
    F*)
        cp \$img tctpersist.img
        ;;
    J*)
        cp \$img persist.img
        ;;
    B*)
        cp \$img boot.img
        ;;
    Y*.mbn)
        cp \$img system.img
        ;;
    [Y|y]*.zip)
        unzip \$img
        mv \${img/zip/mbn.raw} system.img.raw
        ;;
    I*)
        cp \$img cache.img
        ;;
    R*)
        cp \$img recovery.img
        ;;
    [S|s]*)
        cp \$img study.tar
        ;;
    [E|e]*)
        cp \$img splash.img
        ;;
    [U|u]*)
        cp \$img userdata.img
        ;;
    P*)
        cp \$img rawprogram0.xml
        ;;
    esac
fi

\$FLASHTOOL_TELEWEB_BIN --firehose \$firehosepath --rawprogram rawprogram0.xml --imagedir ./
TEOF
    chmod +x ${TMPDIR}/$1/teleweb_flashall.sh
}

# Main
rc=0
path=

TMPDIR=$(zenity --title="Select dir" --file-selection --directory)

while [[ $rc == 0 ]]; do
    #https://172.16.12.62/teleweb Idol4S/Appli/
    choose $WEBHOST $path
    rc=$?
done

if [[ $rc == 2 ]]; then
    gen_md5check $path

    if $FLASHTOOL_FASTBOOT; then
        gen_fastboot_sh $path
    fi
    if $FLASHTOOL_TELEWEB; then
        gen_teleweb_sh $path
    fi

    nautilus ${TMPDIR}/${path}
fi
