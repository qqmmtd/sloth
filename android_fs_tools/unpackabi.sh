#!/usr/bin/env bash

TOOLS_PATH=/home/${USER}/opt/android_fs_tools

PROG=$(basename $0)
usage()
{
    echo "$PROG <boot.img> [output_dir]"
    exit 1
}

##
## main
##
abimage=$1
if [[ ! -r $abimage ]]; then
    usage
fi

output_dir=${2:-${abimage}_out}
#echo output_dir=$output_dir
if [[ ! -e $output_dir ]]; then
    mkdir -p $output_dir
fi

## unpack boot
${TOOLS_PATH}/unpackbootimg -i $abimage -o $output_dir

## unpack ramdisk
gzip -d ${output_dir}/${abimage}-ramdisk.gz
mkdir -p ${output_dir}/root
cd ${output_dir}/root
cpio -i < ../${abimage}-ramdisk

