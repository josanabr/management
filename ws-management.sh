#!/bin/bash
BASE_DIR=/home/clouduser/Src
WS_LOG=${BASE_DIR}/ws-management.py.log
if [ -f ${WS_LOG} ]; then
	mv ${WS_LOG} ${WS_LOG}-`date +"%s"`
fi
python ${BASE_DIR}/ws-management.py >& ${WS_LOG}
