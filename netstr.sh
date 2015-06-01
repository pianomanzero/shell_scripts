#!/bin/bash
trap ctrl_c INT

function ctrl_c(){
 
	isi_for_array -s "killall tcpdump"
	
	tar -cvzf $GZIP_NAME $LOCATION/
	
	exit 0
	
 
 }


#######################################################
##
#   netstr - realtime network testing
#
#######################################################

REMOTE_HOST=$1



#######################################################
##
# Setup portions
#######################################################




 ##############################################
 ##
 # Location of temporary work dir
 ##
 
 LOCATION="/ifs/data/Isilon_Support"
 GZIP_NAME="$LOCATION/`hostname`.$(date +%m%d%Y_%H%M%S)._netstr.tar.gz"
 


 ##
 # Check for /ifs/data/Isilon_Support
 ##
   if [ ! -d $LOCATION ]
   then
    echo "Path: /ifs/data/Isilon_Support does not exist; creating it."
    mkdir $LOCATION
   fi

 LOCATION="$LOCATION/$(date +%m%d%Y)_netstr"
 ##
 # Check if temporary work location exists
 ##
   if [ -d $LOCATION ]
   then
    echo "Error: $LOCATION already exists, please remove then try again."
    exit 1
   else
    mkdir $LOCATION
   fi
 ##

 
 
 PCAP_LOCATION="$LOCATION/pcaps"
 ##
 # Check if pcap location exists
 ##
   if [ -d $PCAP_LOCATION ]
   then
    echo "Error: $PCAP_LOCATION already exists, please remove then try again."
    exit 1
   else
    mkdir $PCAP_LOCATION
   fi
 ##

 
 #####################################################
 ####
 # create individual node hostname dirs
 #######
 mkdir $LOCATION/$(hostname)
 
 
 
 ########################################################
 ##
 # Gather valid interfaces for tcpdumps and start pcaps.
 ##
 
 for i in $(ifconfig | grep flags= | awk -F: '{print $1}' | egrep -v 'lo0|ib0|ib1') 
 do 
	screen -dm nohup tcpdump -i $i -w $PCAP_LOCATION/$(hostname)_$(date +%Y-%m-%d-T%H%M).$i.pcap
	
 done
 
 
 
#######################################################
##
# Action portions
#######################################################
 
 
while true
do 
 
 
 
 
 
 
 #########################################################
 ##
 # Gather ping stats into separate host files per node
 ##
 
 screen -dm ping -c 10 -D $REMOTE_HOST >> $LOCATION/$(hostname)/$(hostname)_$(date +%Y-%m-%d-T%H%M)_remote_ping_test.txt
 
 
 
 
 
 #########################################################
 ##
 # Gather traceroute stats into separate host files per node
 ##
 
 screen -dm traceroute $REMOTE_HOST >> $LOCATION/$(hostname)/$(hostname)_$(date +%Y-%m-%d-T%H%M)_remote_traceroute_test.txt

 sleep 5
 
 
done
