#!/bin/bash

case "$1" in
	"on")
		echo "start gost"
		systemctl start gost
		;;
	"off")
		echo "stop gost"
		systemctl stop gost
		;;
	"kill")
		echo "Killing gost"
		if /sbin/pidof gost > /dev/null; then
			killall -s HUP gost
		fi
		;;
esac

exit 0
