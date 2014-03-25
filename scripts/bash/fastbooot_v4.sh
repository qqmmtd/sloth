#! /bin/bash
#
# fastboot wrapper
#

PRO=$(basename "$0")

# fastboot
FASTBOOT='/opt/bin/fastboot'
if [[ ! -x $FASTBOOT ]]; then
	echo "$PRO: error: invalid $FASTBOOT."
	exit 1
fi
# root permission
if [[ $UID != 0 ]]; then
    FASTBOOT="sudo $FASTBOOT"
fi

# if argc>0, call fastboot directly
if [[ -n $1 ]]; then
    exec $FASTBOOT "$@"
fi

# dir
if [[ -d $ANDROID_PRODUCT_OUT ]]; then
    IMAGE_DIR=$ANDROID_PRODUCT_OUT
else
    IMAGE_DIR=$PWD
fi

# name partition map
declare -A ntop
for img in "$IMAGE_DIR"/*.{img,mbn}; do
    name=${img##*/}
    case $name in
    boot.2knand.img | BB???0??.mbn)
        ntop[$name]='boot'
        ;;
    custpack.2knand.img | MB??ZZ??.mbn)
        ntop[$name]='custpack'
        ;;
    recovery.2knand.img | RB???0??.mbn)
        ntop[$name]='recovery'
        ;;
    system.2knand.img | YB???0??.mbn)
        ntop[$name]='system'
        ;;
    userdata.2knand.img | UB???0??.mbn)
        ntop[$name]='userdata'
        ;;
    *)
        continue
        ;;
    esac
    all="$all $name"
done

if [[ -z $all ]]; then
	echo "$PRO: warning: no image in $IMAGE_DIR."
	exit 1
fi

select img in $all; do
    $FASTBOOT flash ${ntop[$img]} "$IMAGE_DIR/$img"
done

if [[ -n $($FASTBOOT devices) ]]; then
    $FASTBOOT reboot
fi

exit $?

