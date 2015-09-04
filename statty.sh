#!/bin/bash

#####################################################################
## statty.sh
##
## a script for a quick gather of statistical commands
##
## copy to /ifs/data/Isilon_Support
## run with the following command
##  /bin/bash statty.sh >> statty.log 2>& 1
##
## Ctrl C to quit
##
## can be daemonized with:
## nohup /bin/bash/statty.sh >> ./dev/null 2>& 1
##
######################################################################

now=$(date +%M)

ISILOC="/ifs/data/Isilon_Support"

if [ ! -d $ISILOC ]
then
        mkdir $ISILOC
        cd $ISILOC
fi

LOCATION="$ISILOC/$(date +%Y%m%d)_statty_monitor_files"

if [ ! -d $LOCATION ]
then
	mkdir $LOCATION
fi

########## vars for statistics files
        STATSCLIENT="$LOCATION/$(date +%Y%m%d-T%H00)_stats_client"
        STATSHEAT="$LOCATION/$(date +%Y%m%d-T%H00)_stats_heat"
        STATSDRIVE="$LOCATION/$(date +%Y%m%d-T%H00)_stats_drive"
        STATSPROTO="$LOCATION/$(date +%Y%m%d-T%H00)_stats_proto"
while true
do
	if (($now % 5 == 0))
	then
        	echo "$(date +%Y-%m-%d_T%H:%M:%S) - Running statget iteration" >> $LOCATION/statty_run_log.log
                # /bin/bash /ifs/data/Isilon_Support/isiperf_v3.sh -i 4 -e 5 -r 12 -d 1>> $PERFLOG
                echo " " >> $STATSCLIENT && echo "$(date +%Y-%m-%d_T%H:%M:%S) running isi statistics client --totalby=proto --orderby=timeavg,timemax,ops" >> $STATSCLIENT
                isi statistics client --totalby=proto --orderby=timeavg,timemax,ops >> $STATSCLIENT
                sleep 5

                echo "" >> $STATSCLIENT && echo "$(date +%Y-%m-%d_T%H:%M:%S) running isi statistics client --class=read --proto=nfs3   --orderby=timeavg,timemax,ops" >> $STATSCLIENT
                isi statistics client --class=read --proto=nfs3   --orderby=timeavg,timemax,ops >> $STATSCLIENT
                sleep 5

		
                echo "" >> $STATSCLIENT && echo "$(date +%Y-%m-%d_T%H:%M:%S) running isi statistics client --totalby=class --proto=nfs3   --orderby=timeavg,timemax,ops" >> $STATSCLIENT
                isi statistics client --totalby=class --proto=nfs3   --orderby=timeavg,timemax,ops >> $STATSCLIENT
                sleep 5


                echo "" >> $STATSPROTO && echo "$(date +%Y-%m-%d_T%H:%M:%S) running isi statistics protocol --protocols=nfs3" >>$STATSPROTO
                isi statistics protocol --protocols=nfs3 >> $STATSPROTO
                sleep 5


                echo "" >> $STATSHEAT && echo "$(date +%Y-%m-%d_T%H:%M:%S) running isi statistics heat -n 5 --class=read --long" >> $STATSHEAT
                isi statistics heat -n 5 --class=read --long >> $STATSHEAT
                sleep 5

                echo "" >> $STATSDRIVE && echo "$(date +%Y-%m-%d_T%H:%M:%S) running isi statistics drive -n1-5,10 --long --orderby=busy" >> $STATSDRIVE
                isi statistics drive -n1-5,10 --long --orderby=busy >> $STATSDRIVE
                sleep 5


                echo "" >> $STATSDRIVE && echo "$(date +%Y-%m-%d_T%H:%M:%S) running isi statistics drive -n1-5,10  --long --orderby=Queued" >> $STATSDRIVE
                isi statistics drive -n1-5,10 --long --orderby=Queued >> $STATSDRIVE
                sleep 5


                echo "" >> $STATSDRIVE && echo "$(date +%Y-%m-%d_T%H:%M:%S) running isi statistics drive -n1-5,10 --long --orderby=TimeInQ" >> $STATSDRIVE
                isi statistics drive -n1-5,10 --long --orderby=TimeInQ >> $STATSDRIVE
                sleep 5


                sleep 120
	fi
done

