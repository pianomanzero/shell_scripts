#!/bin/bash
#
trap ctrl_c INT

function ctrl_c(){

  package

  exit 0
}

function package(){

  tar -czvf /ifs/data/Isilon_Support/65910284_100214.tgz /ifs/data/Isilon_Support/65910284_100214

  #isi_gather_info -f /ifs/data/Isilon_Support/65910284_100214.tgz 
}


function startup(){

  mkdir /ifs/data/Isilon_Support/65910284_100214
  touch /ifs/data/Isilon_Support/65910284_100214/pinglog.out

  hosts=(63.244.128.135 63.244.85.43 63.244.69.167 63.244.134.91 63.244.134.91 63.244.85.42)
}


function pingit(){

  for h in ${hosts[@]}
  do
    echo "$(date '+%Y-%m-%d-T%H-%M-%S') - capture started for $h" >> /ifs/data/Isilon_Support/65910284_100214/pinglog.out 2>&1
    isi_for_array -s 'screen -dm tcpdump -i lagg0 -C 50 -W 5 -w /ifs/data/Isilon_Support/65910284_100214/$(hostname).$(date '+%Y-%m-%d-T%H-%M-%S').lagg0_01.pcap'
    echo "$(date '+%Y-%m-%d-T%H-%M-%S') - Ping $h"
    isi_for_array -s 'screen -dm ping -c 5 $h >> /ifs/data/Isilon_Support/65910284_100214/pinglog.out 2>&1'
    sleep 6
    isi_for_array -s 'killall tcpdump'
  done


}



function main(){
  startup

  while true
  do
    pingit
  done


}


main
