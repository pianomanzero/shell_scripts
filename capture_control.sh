#!/bin/bash
while true
do
	today=$(date +%-d)
	now=$(date +%M)
	markerdate=$(date -j -v-7d +%m%d%Y)
	yesterday=$(date -j -v-1d +%m%d%Y)
	oldfiles=$(ls | grep "_statistics" | grep -v monitor_archives | wc -l)
	toarchive=$(ls | grep "_statistics" | grep -v monitor_archives)




	if (($today % 7 == 0))
	then

		if (($oldfiles >= 1))
		then
			echo "$(date +%Y-%m-%d) - there are $oldfiles files to be archived" >> ./logfile
			tar -czf $(echo $yesterday)_monitor_archives.tar.gz $toarchive 
			sleep 30
			echo "$(date +%Y-%m-%d) - $oldfiles files have been archived to $(echo $yesterday)_monitor_archives.tar.gz" >> ./logfile

			for i in $(ls | grep "_statistics" | grep -v monitor_archives)
			do
				rm -f $i
				echo "$i removed"
			done

		fi
	fi
	


	if (($now % 10 == 0)) 
	then
		echo "the time is now $(date +%H:%M)" >> ./logfile
		echo "Running cap_and_perf script" >> ./ logfile
		/bin/bash /ifs/data/Isilon_Support/cap_and_perf.sh -i 5 -e 5 -r 12 -d 1>> ./logfile
		sleep 30
	fi
done
