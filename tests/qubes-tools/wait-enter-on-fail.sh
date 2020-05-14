#!/bin/bash

if "$@";
then
	echo "Success" >&2
	sleep 3
	exit 0
else
	echo "Fail, press Enter to continue" >&2
	read stuff
	exit 1
fi
