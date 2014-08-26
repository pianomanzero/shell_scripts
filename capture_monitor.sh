#!/bin/bash
trap ctrl_c INT

function ctrl_c(){
	echo ""
	echo "Ending capture..."
	isi_for_array killall -INT tcpdump
	echo "Ending monitor..."
	echo "ending monitor - $(date)" >> capture_log.out
	mv capture_log.out ./positive_hits/capture_log_$(date '+%Y-%m-%d-T%H%M%S').out
	echo "Compressing files... Please wait..."
	tar -czf 64428756_mon_caps-$(date '+%Y-%m-%d-T%H%M%S').tar.gz ./positive_hits
	echo "Compression complete... cleaning up..."
	tar -czf 64428756_backups-$(date '+%Y-%m-%d-T%H%M%S').tar.gz ./positive_hits
	rm -rf ./positive_hits
	echo "Extiting..."
	exit 0	
}
mkdir positive_hits
L=0
echo "Starting capture..."
isi_for_array -s 'screen -dm tcpdump -i cxgb1 -C 100 -W 25 -w /ifs/data/Isilon_Support/64428756_monitored_captures/$(hostname).$(date '+%Y-%m-%d-T%H-%M-%S').cxgb1_01.pcap' 
sleep 300
echo "Starting Monitor..."
echo "Starting Monitor - $(date)" >> capture_log.out 
while true; do
	for q in $(ls | grep pcap)
	do
		let "L++"	
		echo "Iteration number $L - processing $q"
		if [[ $(tcpdump -r $q | grep -i "no space") ]]
	        then
	                echo "$(date) - NOSPC found in $q in iteration $L" >> capture_log.out
			echo "" >> capture_log.out 
			cp $q ./positive_hits/positive-hit-it_$L-$q
			isi_for_array -s sysctl efs.dexitcode_ring_verbose >> ./positive_hits/$(hostname)-dexitcode.out
		fi
	        done
	echo "sleeping 180 seconds"
        sleep 180
done
																							
