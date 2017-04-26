#!/usr/bin/env bash

TOOLS_PATH=/home/zhanghe/opt/android_fs_tools
AWK_CMD=$(which awk)

PROG=$(basename $0)

usage()
{
    echo "$PROG <system.ext4> [output_dir]"
    exit 1
}

##
## main
##
ext4image=$1
if [[ ! -r $ext4image ]]; then
    usage
fi

output_dir=${2:-${ext4image}_out}
#echo output_dir=$output_dir
if [[ ! -e $output_dir ]]; then
    mkdir -p ${output_dir}/${ext4image}
fi

## sparse to raw
${TOOLS_PATH}/simg2img $ext4image ${output_dir}/${ext4image}.raw

## stat
$AWK_CMD -f ${TOOLS_PATH}/stat.awk -v imgraw=${output_dir}/${ext4image}.raw -v pname=${output_dir}/stat.txt

## extract
$AWK_CMD -f ${TOOLS_PATH}/ext4rdump.awk -v ri=${output_dir}/${ext4image}.raw -v od=${output_dir}/${ext4image}

