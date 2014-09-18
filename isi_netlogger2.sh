#!/bin/bash
trap ctrl_c INT
function ctrl_c(){
	echo ""
	echo "Ending capture..."
	isi_for_array killall -INT tcpdump
	echo "Capture ended - $(date)" >> capture_log.out
	
  compress

  cleanup
  
  echo "Extiting..."
	exit 0	
}

function cleanup(){

  #cleanup and removal operations go here
  echo "Cleaning up..."
  
  rm -rf $CAPDIR

} #end cleanup

function compress(){
	echo "Compressing files... Please wait..."
  tar -czf $SRNUM_captures-$(date '+%Y-%m-%dT%H%M%S').tar.gz $CAPDIR
	echo "Compression complete...."
} #end compress


function startup(){
  PWD=$(pwd)

  if (( $PWD != "/ifs/data/Isilon_Support" ))
  then
    cd /ifs/data/Isilon_Support
  fi
  
  echo "**************************"
  echo "*    isi_netlogger_2     *"
  echo "**************************"

  echo "Please enter an SR number:"
  read SRNUM

  CAPDIR="/ifs/data/Isilon_Support/$SRNUM_pcaps-$(date '+%Y-%m-%d-T%H%M%S')"
  mkdir $CAPDIR

  echo "Which interfaces would you like to capture on? (comma-separated list, no spaces)"
  read ifacein
  #creates array of input: ${IFACES[@]}
  IFACES=$(cut -d',' $ifacein)
  
  echo "How large should each capture file be? (in megabytes)"
  read MEGABYTES

  echo "How many files should be kept before overwriting?"
  read KEEPFILES



} #end startup

function capture(){
  echo "Starting capture..."
    #start log
  echo "Capture started on $(date)" >> $CAPDIR/capture_log.out
  for i in ${IFACES[@]}
  do
    #put stuff here
  echo "Capture started on interface $i" >> $CAPDIR/capture_log.out

    #start capture
    isi_for_array -s 'screen -dm tcpdump -i $i -C $MEGABYTES -W $KEEPFILES -w $CAPDIR/$(hostname).$(date '+%Y-%m-%d-T%H-%M-%S').$i_01.pcap' &>> capture_log.out
    #indicate capture started in log

  done

} #end capture


#main function
function main(){

  startup

} #end main


main
