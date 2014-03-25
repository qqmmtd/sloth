#! /bin/bash

if [[ $(readlink /opt/bin/fastboot) != /bin/su ]]; then
	rm /opt/bin/fastboot
	ln -s /bin/su /opt/bin/fastboot

	if [[ -z $@ ]]; then
		echo "gnome-terminal &"
	elif [[ -f $@ ]]; then
		echo "$(cat "$1")"
	else
		echo "$@"
	fi | sudo fastboot
fi
rm /opt/bin/fastboot
cp /opt/bin/fastboot.bak /opt/bin/fastboot
