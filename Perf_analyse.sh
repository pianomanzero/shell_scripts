#!/bin/bash
############################
# This can be used in conjunction with isiperf.sh (once uploaded with a log gather to Elvis) to get useful analysis information.
# To make this run, it should be placed in an EXPORT directory and permissions configured to allow execute.
############################
#
############################
# Usage and command input
############################
usage()
{
    echo ""
    echo "Usage: Perf_Analyse.sh [ -p Path to specific log to analyse ] [ -l Path to logs for the cluster ] [ -t Type of performance log ] [ -w Write results to file instead of on-screen ] -h for help"
	echo "This script is intended to analyse the results of 'isiperf' when run on a cluster and uploaded with a log gather."
    echo "  -p : Path to the 'isiperf' results (required)"
	echo "  -l : Path to the logs for the cluster (required)"
    echo "  -t : Type of performance log: disk, node, cpu, heat, smb, nfs, network, siq, or job  (required)"
	echo "  -w : Write results to file: ~/results (required)"
	echo "  -r : Number of results to get for each analysis type."
	echo "  -f : Force writing the results, even if the path already exists.  Note: this will overwrite previous data."
    echo "  -h : Print this help"
	echo ""
	echo "  EXAMPLES"
	echo ""
	echo "  Analyse a disk performance log, which will get the top 5, low 5, and averages, and dump results to /logs/Isilon_Systems_-_Global_Support_Lab/2014-04-03-001/Performance_Results/ while overwriting existing data."
	echo "   Perf_Analyse.sh -p /logs/Isilon_Systems_-_Global_Support_Lab/2014-04-03-001/isetta-1/ifs-data-Isilon_Support-ifs-data-Isilon_Support-04022014_ISIPERF.tar/04022014_ISIPERF/  -l /logs/Isilon_Systems_-_Global_Support_Lab/2014-04-03-001 -t disk -w /logs/Isilon_Systems_-_Global_Support_Lab/2014-04-03-001/Performance_Results/ -r 5 -f true"
    echo ""
	echo ""
    exit
}
#
############################
# Get arguments for command execution
############################
OPTS=$1
if [ -z $OPTS ]; then
    OPTS='-h'
fi
#
if [ $OPTS = '-h' ]; then
usage
fi
#
while getopts p:l:t:w:r:f:h opt; do
        case "${opt}"
        in
        p) PATH_ANALYSE=${OPTARG};;
		l) PATH_LOGS=${OPTARG};;
		t) TYPE_ANALYSE=${OPTARG};;
		w) PATH_WRITE=${OPTARG};;
		r) NUM_RES=${OPTARG};;
		f) FORCE_WRITE=${OPTARG};;
        \?)
		  echo "Invalid option: -$OPTARG" >&2
		  exit 1
		  ;;
		:)
		  echo "Option -$OPTARG requires an argument.  Use -h for help" >&2
		  exit 1
		  ;;
        esac
done
############################
# Check for output write path, if none exists, create it.
############################
  if [ -d $PATH_WRITE ] && [ $FORCE_WRITE -eq "true" ];
  then
  rm -rf $PATH_WRITE; mkdir $PATH_WRITE;
  elif [ ! -d $PATH_WRITE ];
  then mkdir $PATH_WRITE;
  elif [ -d $PATH_WRITE ] && [ $FORCE_WRITE -eq "false" ];
  then echo "Error: $PATH_WRITE already exists, please select an alternate path, or remove the old one.";
		exit 1;
   fi
############################
# Functions & Variables
############################
NUM_DRIVES=$(grep -E '[0-9]{1,3}:[0-9]{1,3}' $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|cut -d \: -f2| cut -d \  -f 1|sort -nu)
NUM_NODES=$(grep -v % $PATH_LOGS/nodes_info|awk '{print $3}'|wc -l)
NAME_NODES=$(grep -v % $PATH_LOGS/nodes_info|awk '{print $1}')
SATA_POOLS=$(grep -E '[0-9]{1,3}'\:'[0-9]{1,3}' $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|sort -k2|grep -v "SSD|SAS")
SAS_POOLS=$(grep -E '[0-9]{1,3}'\:'[0-9]{1,3}' $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|sort -k2|grep -v "SSD|SATA")
SSD_POOLS=$(grep -E '[0-9]{1,3}'\:'[0-9]{1,3}' $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|sort -k2|grep -v "SAS|SATA")
DISK_POOLS=$(awk '{print $1,$2,$3,$4}' $PATH_LOGS/local/isi_diskpool|grep -Ev "\-\-\-\-|Unprov|Type|Id"|awk 'NF >0'|grep " D "|cut -d D -f 2-|sed 's/bay/\ /g')
ONEFS=$(cat $PATH_LOGS/*/uname|awk '{print $4}'|cut -c 2)
#
#
GET_DRIVE_AVERAGES()
{
for i in $NUM_NODES; do echo "Analysis of Node: "$i;echo "=========================";grep -E ${i}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{l +=$8}{print "The Average Latency per disk on this node is: "l/NR"ms."}'|tail -1;echo "=========================";grep -E ${i}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{i +=$3}{o +=$5}{print "The Average IOPs per disk on this node is: "(i/NR)+(o/NR)"."}'|tail -1;done
}
#
GET_DRIVE_TOP_ONE()
{
for p in ${NAME_NODES}; do echo "Analysis of Node: "$p;echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The Highest IOPs in is on Drive: "$1".  Which has: "$3" IOPs, "$3"B of throughput in, "$4"B of throughput out, and "$5" IOPs out."}'|sort -k11n|tail -1; echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The Highest IOPs out is on Drive: "$1".  Which has: "$5" IOPs, "$3"B of throughput in, "$4"B of throughput out, and "$3" IOPs in."}'|sort -k11n|tail -1; echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The Highest disk latency is on Drive: "$1".  Which has: "$8" ms, "$3"B of throughput in, "$4"B of throughput out, "$5" or IOPs in, and "$3" IOPs out."}'|sort -k11n|tail -1;done
}
#
GET_DRIVE_BOTTOM_ONE()
{
for p in ${NAME_NODES}; do echo "Analysis of Node: "$p;echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The Lowest IOPs in is on Drive: "$1".  Which has: "$3" IOPs, "$3"B of throughput in, "$4"B of throughput out, and "$5" IOPs out."}'|sort -k11rn|tail -1; echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The Lowest IOPs out is on Drive: "$1".  Which has: "$5" IOPs, "$3"B of throughput in, "$4"B of throughput out, and "$3" IOPs in."}'|sort -k11rn|tail -1; echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The Lowest disk latency is on Drive: "$1".  Which has: "$8" ms, "$3"B of throughput in, "$4"B of throughput out, "$5" or IOPs in, and "$3" IOPs out."}'|sort -k11rn|tail -1;done
}
#
GET_DRIVE_TOP()
{
for p in ${NAME_NODES}; do echo "Analysis of Node: "$p;echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The top IOPs in is found on Drive(s): "$1".  Which have: "$3" IOPs, "$4"B of throughput in, "$6"B of throughput out, and "$5" IOPs out."}'|sort -k11n|tail -${NUM_RES}; echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The top IOPs out is found on Drive(s): "$1".  Which have: "$5" IOPs, "$4"B of throughput in, "$6"B of throughput out, and "$3" IOPs in."}'|sort -k11n|tail -${NUM_RES}; echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The top disk latency is found on Drive(s): "$1".  Which have: "$8" ms, "$4"B of throughput in, "$6"B of throughput out, "$3" or IOPs in, and "$5" IOPs out."}'|sort -k11n|tail -${NUM_RES};done
}
#
GET_DRIVE_BOTTOM()
{
for p in ${NAME_NODES}; do echo "Analysis of Node: "$p;echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The bottom IOPs in is found on Drive(s): "$1".  Which have: "$3" IOPs, "$4"B of throughput in, "$6"B of throughput out, and "$5" IOPs out."}'|sort -k11rn|tail -${NUM_RES}; echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The bottom IOPs out is found on Drive(s): "$1".  Which have: "$5" IOPs, "$4"B of throughput in, "$6"B of throughput out, and "$3" IOPs in."}'|sort -k11rn|tail -${NUM_RES}; echo "=========================";grep -E " "${p}\: $PATH_ANALYSE/All_Nodes.DISK.disk_latency.txt|awk '{print "The bottom disk latency is found on Drive(s): "$1".  Which have: "$8" ms, "$4"B of throughput in, "$6"B of throughput out, "$3" or IOPs in, and "$5" IOPs out."}'|sort -k11rn|tail -${NUM_RES};done
}
#
GET_DRIVE_DISKPOOLS()
{
echo;echo;echo "=========================";for i in $(echo $DISK_POOLS|xargs -n2|awk '{print $1}'|sort|uniq); do echo "Analysis of Disk Pools on Nodes "$i;echo "=========================";echo $DISK_POOLS|xargs -n2|grep $i|awk '{print "Disk Pool Members are, drives: "$2}'; done; 
}
#
#
GET_DRIVE_ANALYSIS()
{
if [ -d $PATH_WRITE/drive_stats ]
  then
   echo "Error: $PATH_WRITE already exists, would you like to overwrite the old path?"
   read yesorno;
   if echo ${yesorno} [ -eq "yes" ]; then
   rm -rf $PATH_WRITE; mkdir $PATH_WRITE/drive_stats/;
   else echo "Please remove the existing "$PATH_WRITE" path or select an alternative path to write to.";
   fi
   exit 1
  else
   mkdir $PATH_WRITE/drive_stats;
  fi
#
GET_DRIVE_AVERAGES > $PATH_WRITE/drive_stats/DRIVE_AVERAGES_PER_NODE.txt;
GET_DRIVE_TOP_ONE > $PATH_WRITE/drive_stats/DRIVE_TOP_ONE.txt;
GET_DRIVE_BOTTOM_ONE > $PATH_WRITE/drive_stats/DRIVE_BOTTOM_ONE.txt;
GET_DRIVE_TOP > $PATH_WRITE/drive_stats/DRIVE_TOP.txt;
GET_DRIVE_BOTTOM > $PATH_WRITE/drive_stats/DRIVE_TOP.txt;
GET_DRIVE_DISKPOOLS > $PATH_WRITE/drive_stats/DRIVE_DISKPOOLS.txt;
}
#
GET_NODE_ANALYSIS()
{
echo $TYPE_ANALYSE " is not yet implemented."
}
#
GET_CPU_ANALYSIS()
{
echo $TYPE_ANALYSE " is not yet implemented."
}
#
GET_HEAT_ANALYSIS()
{
echo $TYPE_ANALYSE " is not yet implemented."
}
#
GET_SMB_ANALYSIS()
{
echo $TYPE_ANALYSE " is not yet implemented."
}
#
GET_NFS_ANALYSIS()
{
echo $TYPE_ANALYSE " is not yet implemented."
}
#
GET_SIQ_ANALYSIS()
{
echo $TYPE_ANALYSE " is not yet implemented."
}
#
GET_JOB_ANALYSIS()
{
echo $TYPE_ANALYSE " is not yet implemented."
}
#
GET_NETWORK_ANALYSIS()
{
if [ -d $PATH_WRITE/network_stats ]
  then
   echo "Error: $PATH_WRITE already exists, would you like to overwrite the old path?"
				read yesorno;
   if echo ${yesorno} [ -eq "yes" ]; then
				rm -rf $PATH_WRITE; mkdir $PATH_WRITE/network_stats;
		else echo "Please remove the existing "$PATH_WRITE" path or select an alternative path to write to.";
   fi
		exit 1
		else
				mkdir $PATH_WRITE/network_stats;
  fi
for n in $NAME_NODES; do echo "Analysing Node: "$n;grep -A1 "Time" $PATH_ANALYSE/All_Nodes.NETWORK.network_throughput.txt |grep $n|grep -v "Time"|awk '{i += $2}{o += $3}{print "Total Throughput on this Node is: "(i+o/NR)/1024" MBps" }'|tail -1; done > $PATH_WRITE/network_stats/NETWORK_THROUGHPUT.txt
}
#
#
############################
# Run the functions
############################
#
#
if [ $(echo $ONEFS) == "7" ];then
if [ $(echo ${TYPE_ANALYSE}) == disk ]; then
GET_DRIVE_ANALYSIS &
elif [ $(echo ${TYPE_ANALYSE}) == node ]; then
GET_NODE_ANALYSIS &
elif [ $(echo ${TYPE_ANALYSE}) == cpu ]; then
GET_CPU_ANALYSIS &
elif [ $(echo ${TYPE_ANALYSE}) == heat ]; then
GET_HEAT_ANALYSIS &
elif [ $(echo ${TYPE_ANALYSE}) == smb ]; then
GET_SMB_ANALYSIS &
elif [ $(echo ${TYPE_ANALYSE}) == nfs ]; then
GET_NFS_ANALYSIS &
elif [ $(echo ${TYPE_ANALYSE}) == siq ]; then
GET_SIQ_ANALYSIS &
elif [ $(echo ${TYPE_ANALYSE}) == job ]; then
GET_JOB_ANALYSIS &
elif [ $(echo ${TYPE_ANALYSE}) == network ]; then
GET_NETWORK_ANALYSIS &
fi
elif [ -z ]; then echo "Invalid Path to Log set.";
else echo "This script will only work with OneFS version 7 and greater."
fi

