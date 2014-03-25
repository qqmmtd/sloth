#! /bin/bash

find_program ()
{
	local p=$(which $1 2>/dev/null)
	if [[ -z $2 ]]; then
		echo $p
	else
		eval CMD_$2=\"$p\" # command 'eval' is not safe
	fi
}

gen_img_list ()
{
	$SED -n '/class="BDE_Image"/{s/"/\n/g;p}' $1/* | $SED -n '/jpg$/p' > $1/img.list
}

tieba_img ()
{
	local prefix=${1%\?pn=*} i
	local dir=${prefix##*/}
	if [[ ! -f $dir/page.list.done ]]; then
		mkdir -pv $dir
		for ((i=1; i<=$2; ++i)); do
			echo "${prefix}?pn=$i"
		done > $dir/page.list
		$WGET -c -nv -i $dir/page.list -P $dir
		mv $dir/page.list $dir/page.list.done
	fi
	if [[ ! -f $dir/img.list.done ]]; then
		gen_img_list $dir
		$WGET -c -nv -i $dir/img.list -P $dir
		mv $dir/img.list $dir/img.list.done
	fi
	
	return $?
}

SED=$(find_program sed)
WGET=$(find_program wget)

tieba_img "$@"
