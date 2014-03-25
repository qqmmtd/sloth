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
for img in "$IMAGE_DIR"/*.{img,ext4}; do
    name=${img##*/}
    case $name in
    boot.img|boot.2knand.img)
        ntop[$name]='boot'
        ;;
    userdata.img.ext4|userdata.2knand.img|userdata.img)
        ntop[$name]='userdata'
        ;;
    system.img.ext4|system.2knand.img|system.img)
        ntop[$name]='system'
        ;;
    custpack.img.ext4|custpack.2knand.img|custpack.img)
        ntop[$name]='custpack'
        ;;
    recovery.img|recovery.2knand.img)
        ntop[$name]='recovery'
        ;;
    cache.img.ext4|cache.img)
        ntop[$name]='cache'
        ;;
    persist.img)
        ntop[$name]='persist'
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

