#!/bin/bash
PORTWSM=8008
WSMPATH="/home/clouduser/Src"
OUTPUT=`sudo netstat -atunp | grep ${PORTWSM}` 
if [ "x" == "x${OUTPUT}" ]; then
	${WSMPATH}/ws-management.sh &
	if [ ! $? == 0 ]; then
		echo "Error starting ${0}" >> ${WSMPATH}/startWSM.sh.log
	fi
fi
