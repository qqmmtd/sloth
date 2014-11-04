#!/bin/bash

#WEBUSER='nbrootSh'
#WEBPASSWORD='nb456Sh#'
#WEBHOST='http://172.16.11.171'
WEBHOST='https://172.16.12.62/teleweb'

TMPDIR='/tmp/tmp.teleweb'

function fetch()
{
#    wget --user=$WEBUSER --password=$WEBPASSWORD --quiet --continue $1 -O $2
    wget --no-check-certificate --quiet --continue $1 -O $2
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
    cat > ${TMPDIR}/${path}/flashall.sh << EOF
#!/bin/bash

# Debug
#ECHO='echo'

# Set adb & fastboot path here
ADB='adb'
FASTBOOT='fastboot'

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

function do_nothing()
{
    echo "do nothing: \$@"
}

# Main
# reboot into bootloader
\$ECHO \$ADB reboot bootloader

# show partitions detail
echo 'partitions:'
awk 'BEGIN { FS = "[\" ]"; } /<program/ && !/GPT/ { printf("%s %s%s %s%s %s%s\n", \$14, \$37, \$38, \$16, \$17, \$10, \$11); }' P*.mbn

# gen gpt_both0.bin
cat O*.mbn G*.mbn > gpt_both0.bin

# flash partition table
read -p 'flash partition table? [Y|y] ' ans;
case \$ans in
[Y|n]) do_flash partition gpt_both0.bin;;
*) ;;
esac

# erase partitions
for pn in \$(sed -n '/GPT/d;/<zeroout"/{s/^.*label="//;s/".*\$//p}' P*.mbn); do
    do_erase \$pn
done

# flash images
for img in *.{mbn,zip}; do
    case \$img in
    N*) do_flash modem \$img;;
    W*) do_flash rpm \$img
        do_flash rpmbk \$img
        ;;
    C*) do_flash sbl1 \$img
        do_flash sbl1bk \$img
        ;;
    T*) do_flash tz \$img
        do_flash tzbk \$img
        ;;
    D*) do_flash sdi \$img;;
    S*) do_flash fsg \$img;;
    L*) do_flash aboot \$img
        do_flash abootbk \$img
        ;;
    F*) do_flash tctpersist \$img;;
    J*) do_flash persist \$img;;
    E*) do_flash splash \$img;;
    B*) do_flash boot \$img;;
    Y*.mbn) do_flash system \$img;;
    Y*.zip) unzip \$img
            do_flash system \${img/zip/mbn.raw}
            ;;
    I*) do_format cache;;
    U*) do_format userdata;;
    R*) do_flash recovery \$img;;
    M*.mbn) do_flash custpack \$img;;
    M*.zip) unzip \$img
            do_flash custpack \${img/zip/mbn.raw}
            ;;
    *) do_nothing \$img
       continue
       ;;
    esac
done

# reboot
\$ECHO \$FASTBOOT -i 0x1bbb reboot
EOF
    chmod +x ${TMPDIR}/${path}/flashall.sh
    nautilus ${TMPDIR}/${path}
fi
