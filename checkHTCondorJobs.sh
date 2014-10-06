#!/bin/bash
#
# This script checks for HTCondor jobs using the "condor_q" command.
# If there are at least one job, it invokes a web service for each machine
# defined in the ${SHAREDDIR}/${MACLIST} file to start it up.
# Otherwise, if there are not jobs, it invokes a web service for each machine
# defined in the ${SHAREDDIR}/${MACLIST} file to shut it down.
#
# This page http://superuser.com/questions/149329/what-is-the-curl-command-line-syntax-to-do-a-post-request
# explains how to request a post web service using the curl command
#
# Author: John Sanabria
# e-mail: john.sanabria@gmail.com
# Date: June 5, 2014
#  
# Variables definition
#
CONDOR_HOME=/opt/condor806
SHAREDDIR=/shared/management
MACLIST=${SHAREDDIR}/maclist # where machines to be turning on or turning off
                             # are defined
LOGFILE=${HOME}/checkHTCondorJobs.log
NOW=`date +"%x %X"`
WEBSERVICE="http://172.17.9.50:8008" # where web service is running
TURNONENDPOINT="turnonws" 
TURNOFFENDPOINT="turnoffws"
#
# This command initializes some env variables
. ${CONDOR_HOME}/condor.sh
#Delete the tasks that are on hold
for i in $(condor_q -hold | tr -s ' ' | cut -f2 -d ' ' ); do
	condor_rm $i
done
# Gets number of jobs pending to be run
HTCONDORJOBS=`${CONDOR_HOME}/bin/condor_q | tail -1 | cut -d ';' -f 1 | cut -d ' ' -f 1`
echo "[${HTCONDORJOBS}]" >> ${LOGFILE}
if [[ ! -f ${MACLIST} ]]; then # maclist file does not exist
	echo "${NOW} - ${MACLIST} file is not accessible"  >> ${LOGFILE}
	exit -1
fi 
# validation if curl is available
CURL=`which curl`
if [[ "x${CURL}" == "x" ]]; then # curl command is not available
	echo "${NOW} - curl is not installed"  >> ${LOGFILE}
	exit -1
fi
if [[ ! "x${HTCONDORJOBS}" == "x0" ]]; then  # number of jobs different from 0
	echo "${NOW} - Number of HTCondor jobs: ${HTCONDORJOBS}" >> ${LOGFILE}
	echo "${NOW} - Booting up workstations" >> ${LOGFILE} 
	for i in `cat ${MACLIST} | cut -d '|' -f 1`; do
		echo "${NOW} - Staring machine with id ${i}" >> ${LOGFILE}
		curl --data "machineid=${i}" ${WEBSERVICE}/${TURNONENDPOINT} >> ${LOGFILE}
	done
else  # there are jobs in the queue
	echo "${NOW} - Number of HTCondor jobs: ${HTCONDORJOBS}" >> ${LOGFILE}
	echo "${NOW} - Shutting down workstations" >> ${LOGFILE} 
	for i in `cat ${MACLIST} | cut -d '|' -f 3`; do
		ping -c 1 ${i} >& /dev/null
		if [ $? == 0 ]; then # machine is alive
			echo "${NOW} - Shuttding down machine with IP ${i}" >> ${LOGFILE}
			curl --data "machineid=${i}" ${WEBSERVICE}/${TURNOFFENDPOINT} >> ${LOGFILE}
		fi
	done
fi
