#!/bin/bash

device=$(xinput --list | grep TouchPad | sed -e 's/^.*id=\([0-9]*\).*$/\1/')

state=$(xinput --list-props $device | grep Enabled | awk -F: '{print $2}')

if (echo $state | grep -q 1); then
	xinput set-prop $device "Device Enabled" 0
else 
	xinput set-prop $device "Device Enabled" 1
fi

