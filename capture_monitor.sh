#!/bin/bash
trap ctrl_c INT

function ctrl_c(){
	echo ""
	echo "Ending capture..."
  killcap
	echo "Ending monitor..."
  echo "$(date '+%Y-%m-%d-T%H%M%S') - Ending monitor" >> capture_log.out
	echo "Compressing files... Please wait..."
  package

	echo "Compression complete... cleaning up..."
  cleanup
	echo "Extiting..."
	exit 0	
}


function setup(){

  #startup functions go here
  mkdir positive_hits
  echo "$(date '+%Y-%m-%d-T%H%M%S') - Starting new log" > capture_log.out

} #end startup

function cleanup(){

  #cleanup functions go here
  #before removing items, backup all items to be removed.
  tar -czf 64428756_backups-$(date '+%Y-%m-%d-T%H%M%S').tar.gz ./positive_hits
  
  #move backups to Isilon_Support directory
  for b in $(ls | grep -i "_backups")
  do
    mv $b ../$b
  done

	rm -rf ./positive_hits
  for r in $(ls | grep -i ".pcap")
  do
    rm -f $r
  done

} #end cleanup

function package(){

  #packaging functions go here
  mv capture_log.out ./positive_hits/capture_log_$L-$(date '+%Y-%m-%d-T%H%M%S').out
  ARCHIVE_FILE="64428756_mon_caps-$(date '+%Y-%m-%d-T%H%M%S').tar.gz"
	tar -czf $ARCHIVE_FILE ./positive_hits

} #end package


function startcap(){
  #capture functionality 
  echo "$(date '+%Y-%m-%d-T%H%M%S') - Starting capture" >> capture_log.out
  isi_for_array -s 'screen -dm tcpdump -i cxgb1 -C 25 -W 40 -w /ifs/data/Isilon_Support/64428756_monitored_captures/$(hostname).$(date '+%Y-%m-%d-T%H-%M-%S').cxgb1_01.pcap' 

} #end startcap


function monitor(){

  #monitoring functions go here

  sleep 60
  echo "Starting Monitor..."
  echo "$(date '+%Y-%m-%d-T%H%M%S') - Starting Monitor" >> capture_log.out 
  while true; do
	  for q in $(ls | grep pcap)
	  do
		  let "L++"	
		  echo "Iteration number $L - processing $q"
		  if [[ $(tcpdump -r $q | grep -i "no space") ]]
	    then
        killcap
	      echo "$(date) - NOSPC found in $q in iteration $L" >> capture_log.out
			  mv $q ./positive_hits/positive-hit_$L-$q
        echo "$(date '+%Y-%m-%d-T%H%M%S') - Collecting dexitcode info for iteration $L" >> capture_log.out 
        isi_for_array -s sysctl efs.dexitcode_ring_verbose >> ./positive_hits/iteration-$L-$(date '+%Y%m%dT%H%M%S')-dexitcode.out
        echo "$(date '+%Y-%m-%d-T%H%M%S') - Collecting process log for iteration $L" >> capture_log.out 
        isi_for_array -s ps -auwwx >> ./positive_hits/process_log-$L-$(date '+%Y%m%dT%H%M%S').out
        echo "$(date '+%Y-%m-%d-T%H%M%S') - Collecting kern.proc.all_stacks log for iteration $L" >> capture_log.out 
        isi_for_array -s sysctl kern.proc.all_stacks >> ./positive_hits/kern.proc.all_stacks-$L-$(date '+%Y%m%dT%H%M%S').out
        package
        cleanup
        setup
        startcap
		  fi
	  done
        sleep 10
  done

} #end monitor

function killcap(){

  #killing functionality goes here
	echo ""
  echo "$(date '+%Y-%m-%d-T%H%M%S') Ending capture" >> capture_log.out
	isi_for_array killall -INT tcpdump
  sleep 1

} #end killcap


function firstrun(){
  #function to check to see if we're in the proper dir, if not change to it
  #and clear out any existing garbage in our proper diretory before running
  
  if [[ ! -d "/ifs/data/Isilon_Support/64428756_monitored_captures" ]]
  then
    mkdir /ifs/data/Isilon_Support/64428756_monitored_captures
  else
    echo "/ifs/data/Isilon_Support/64428756_monitored_captures already exists"
  fi

  if [[ $(pwd) != "/ifs/data/Isilon_Support/64428756_monitored_captures" ]]
  then
    cd "/ifs/data/Isilon_Support/64428756_monitored_captures"
  else
    echo "Alread in /ifs/data/Isilon_Support/64428756_monitored_captures"
  fi

  for g in $(ls | grep -i ".pcap")
  do
    rm -f $g
  done


  setup
  echo "Starting capture..."
  startcap
} #end firstrun

function main(){
  L=0
  firstrun
  monitor

} #end main

main
