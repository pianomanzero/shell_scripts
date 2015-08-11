#!/bin/bash

#########################################################################
## mon_control.sh ver 1.5 - control script for rotating isiperf captures
## 
## README: 
## This script is to be used in conjunction with isiperf_v2.sh
## Both this script and isiperf_v2.sh should be copied to the Isilon
## Support directory (/ifs/data/Isilon_Support)
##
## Daemonize this script with nohup for best results:
## nohup /bin/bash mon_control.sh >> ./dev/null 2>& 1
##
## locate the currently running process ID with the following:
## isi_for_array -s “ps auwwx | grep mon_control | grep -v grep”
##
## the process can then be killed with kill -9 <PID>
##
## -- TWM, 2015
#########################################################################

ISILOC="/ifs/data/Isilon_Support"

if [ ! -d $ISILOC ]
then
	mkdir $ISILOC
	cd $ISILOC
fi
	

while true
do
	yesterday=$(date -j -v-1d +%Y%m%d)
	today=$(date +%Y%m%d)
	now=$(date +%M)
	lasthour=$(date -j -v-1H +%Y-%m-%d-T%H%M)
	oldfiles=$(ls | egrep "_statistics|_statslog" | egrep -v "monitor_archives|$GZIP_NAME" | wc -l)
	toarchive=$(ls | egrep "_statistics|_statslog" | egrep -v "monitor_archives|$GZIP_NAME")
	CLEANUPDIRS=$(ls | egrep "_monitor_files" | egrep -v "ready_for_upload.tar.gz|$(date +%Y%m%d)")
	LOCATION="$ISILOC/$(date +%Y%m%d)_monitor_files"
	GZIP_NAME="$ISILOC/$(date -j -v-1d +%Y%m%d)_monitor_files_ready_for_upload.tar.gz"
	MONLOG="$LOCATION/$(date +%Y%m%d%H)_mon_control_logfile"
	STATSLOG="$LOCATION/$(date +%Y%m%d%H)_mon_control_statslog"
	PERFLOG="$LOCATION/$(date +%Y%m%d%H)_mon_control_perflog"

	
	if [ ! -d $LOCATION ]
	then
		mkdir $LOCATION
	fi

	if [ -d $(echo $yesterday)_monitor_files ]
	then
		echo "$(date +%Y%m%d_T%H:%M:%S) - There's a directory ready to be compressed" >> $MONLOG
		tar -czvf $GZIP_NAME $(echo $yesterday)_monitor_files
                echo "$(date +%Y%m%d_T%H:%M:%S) - $GZIP_NAME has been compressed and is ready for upload" >> $MONLOG
	elif [ $(echo $CLEANUPDIRS | wc -w) != 0 ] 
	then
		echo "$(date +%Y%m%d_T%H:%M:%S) - There are $(echo $CLEANUPDIRS | wc -w) old dirs needing cleanup" >> $MONLOG
		for d in $(ls | egrep "_monitor_files" | egrep -v "ready_for_upload.tar.gz|$(date +%Y%m%d)")
		do 
			rm -rf $d
			echo "$(date +%Y%m%d_T%H:%M:%S) - removed $d" >> $MONLOG
		done
		
	else
		echo "$(date +%Y%m%d_T%H:%M:%S) - No files from yesterday to archive" >> $MONLOG
	fi







	if (($now == 55))
	then

		if (($oldfiles >= 1))
		then
			echo "$(date +%Y-%m-%d_T%H:%M:%S) - there are $oldfiles files to be archived" >> $MONLOG
			
			for i in $(echo $toarchive | cut -f 1-10000 -d " ")
			do
				mv $i $LOCATION
			done
				
			for k in $(ls | grep "$(date +%m%d%Y)" | grep -v "_ISIPERF")
			do	
				mv $k $LOCATION
			done

			sleep 30
			echo "$(date +%Y-%m-%d) - $oldfiles files have been sent to $LOCATION" >> $MONLOG



		fi
	fi
	

	if (($now % 10 == 0)) 
	then
		echo "$(date +%Y-%m-%d_T%H:%M:%S) - Running isiperf script" >> $MONLOG
		/bin/bash /ifs/data/Isilon_Support/isiperf_v2.sh -i 4 -e 5 -r 12 -d 1>> $PERFLOG
		sleep 280
		echo "$(date +%Y-%m-%d_T%H:%M:%S) - nlm sessions, all nodes" >> $STATSLOG
		isi_for_array -s isi nfs nlm sessions list >> $STATSLOG && echo "" >> $STATSLOG
		echo "$(date +%Y-%m-%d_T%H:%M:%S) - nlm locks, all nodes" >> $STATSLOG
		isi_for_array -s isi nfs nlm locks list >> $STATSLOG && echo "" >> $STATSLOG
		echo "$(date +%Y-%m-%d_T%H:%M:%S) - rpc procs, all nodes" >> $STATSLOG
		isi_for_array -n1 -s "ps auwwx | head -n1" >> $STATSLOG  && isi_for_array -s ps auwwx | egrep "nfs|rpc" >> $STATSLOG && echo "" >> $STATSLOG

	fi
done
