#!/bin/bash

if [ "$2" = "--strip-deb" ];
then
	head -n 1 "$1" | sed -e 's/^.*(\([^)]*\)).*$/\1/' -e 's/-[0-9]*$//'
else
	head -n 1 "$1" | sed -e 's/^.*(\([^)]*\)).*$/\1/'
fi
