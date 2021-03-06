#!/bin/bash
#
#-errorgrab v2.0.1
#-A script to grab errors from message files
#
#- in development:
#- find logspam, multiple
#
#

#startup function
function startup (){
echo "**************************************"
echo "**        errorgrab v. 2.0.1.1      **"
echo "**************************************"
echo ""
echo "Checking current directory..."

username="$(whoami)"

echo "Hello $username"

loc="$(pwd)"
rootdir="$loc"
messageDir="$loc/messages"
hwdir="$loc/isi_hw_status"


echo "Our current location is $rootdir . Is this the root of the logset? (y/n)"
read atroot

if [ "$atroot" = "y" ]
then
  clear
  loadnodes
  MAINF
else
  echo "Please re-run this script from the root of the logset"
  exit 0
fi
} #end startup


#message search
function message_search(){
  echo "Looking for messages logs..."

  changedir $messageDir

  echo "What are you searching for? (case insensitive)"
  read searchby

  echo "How far back would you like to search? (date format YYYY-MM-DD, format can be a fragmnet like YYYY-MM or YYYY)"
  read timeframe

  echo "Would you like to output the results to a file? (y/n)"
  read writefile

  if [ $writefile = "y" ]
  then
    myfilename="messages_$(date +%m%d%Y)_$searchby"
    echo "Results will be written to $myfilename"
  fi

  FILECOUNT="$(ls $loc | grep -v ^l | wc -l)"


  FILELIST=("$(ls $loc | sort -V)")

  echo "Looking for files in $(pwd)"
  echo  ""
  echo "There are $FILECOUNT files in $(pwd)" 

  echo "The search param is $searchby"

  if [ $writefile = "y" ]
  then

    for x in $FILELIST
      do
      echo "----------------------------------------------------" >> $myfilename
      echo "$x  Search parameter: $searchby" >> $myfilename
      echo "----------------------------------------------------" >> $myfilename
      result="$(grep -i $searchby $x | grep -i $timeframe | sort | uniq -f3)"
      echo "$result" >> $myfilename
      echo "" >> $myfilename
    done
  else

    for x in $FILELIST
      do
      echo "----------------------------------------------------"
      echo "$x  Search parameter: $searchby"
      echo "----------------------------------------------------"
      result="$(grep -i $searchby $x | grep -i $timeframe | sort | uniq -f2)"
      echo "$result"
      echo ""
    done 
  fi



  changedir $rootdir
  #exit 0
  MAINF
} #end message file search

function messagetails(){

  changedir $messageDir

  echo "How many lines from the end of the file would you like to grab?"
  read lines

  echo "Would you like to output the results to a file? (y/n)"
  read writefile

  if [ $writefile = "y" ]
  then
    myfilename="messageTails_$(date +%m%d%Y)_$lines"
    echo "Results will be written to $myfilename"
  fi

  FILECOUNT="$(ls $loc | grep -v ^l | wc -l)"


  FILELIST=("$(ls $loc | sort -V)")

  echo "Looking for files in $(pwd)"
  echo  ""
  echo "There are $FILECOUNT files in $(pwd)" 

  if [ $writefile = "y" ]
  then

    for x in $FILELIST
      do
      echo "----------------------------------------------------" >> $myfilename
      echo "Message Tail $x" >> $myfilename
      echo "----------------------------------------------------" >> $myfilename
      result="$(tail -n $lines $x)"
      echo "$result" >> $myfilename
      echo "" >> $myfilename
    done
    echo "Output has been written to $myfilename"
  else

    for x in $FILELIST
      do
      echo "----------------------------------------------------"
      echo "Message Tail $x" >> $myfilename
      echo "----------------------------------------------------"
      result="$(tail -n $lines $x)"
      echo "$result"
      echo ""
    done 
  fi



  changedir $rootdir
MAINF
} #end messagetails

function changedir() {

  cd $1
  loc="$(pwd)"
}

#hw scan
function hwscan(){
  echo ""
  echo ""
  echo "That functionality isn't quite ready yet. Check for updates soon"
  echo ""
  MAINF
}
#end hw scan

#rollup patch check
function rollup(){
  echo ""
  echo ""
  echo "This functionality isn't ready yet, but will query for SMB rollup patch status"
  echo "check for updates soon"
  echo ""
  MAINF

}
#end rollup patch check

#general health check
# :: TODO :: add option to prepend SR number to file

function healthy(){
  echo "Running simple health check....."
  echo ""
  myfile="simple_health_check_$(date +%m%d%Y)"
  echo "Output will be written to $myfile"
  echo "Checking cluster status..."
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo ":    OneFS Version: $VERSION      :" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile

  #check isi_status
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo ":           isi status            :" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  cat ${nodeArray[1]}/isi_status >> $myfile
  echo "" >> $myfile
  echo "Checking boot drives..."

  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo ":           boot drives           :" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo "" >> $myfile

  for dir in ${nodeArray[@]}
  do
    echo $dir >> $myfile
    grep -i 'ad4\|ad7' $dir/atacontrol >> $myfile
    echo "" >> $myfile
  done
  
  for dir in ${nodeArray[@]}
  do
    echo $dir >> $myfile
    grep -i complete $dir/gmirror_status | wc -l >> $myfile
    echo "" >> $myfile
  done

  echo "Check for degraded boot drives" >> $myfile
  
  for dir in ${nodeArray[@]}
  do
    echo $dir >> $myfile
    grep -i degraded $dir/gmirror_status
    echo ""
  done

  echo "" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo ":   Check root partition space    :" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo "" >> $myfile
 
  for dir in ${nodeArray[@]}
  do
    echo $dir >> $myfile
    grep -i root $dir/df >> $myfile
    echo ""
  done

  echo "" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo ":      Check hardware status      :" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo "" >> $myfile
 
  for dir in ${nodeArray[@]}
  do
    echo $dir >> $myfile
    cat $dir/isi_hw_status | grep -A 5 -i 'Battery1:' >> $myfile 
    echo ""
    cat $dir/isi_hw_status | grep -A 2 - 'PwrSupl' >> $myfile
    echo ""
  done
  
  echo "" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo ":         Firmware Status         :" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo "" >> $myfile
  cat $loc/firmware >> $myfile
  echo ""


  
  
  echo "" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo ":   Group statement consistency   :" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo "" >> $myfile
  
  for dir in ${nodeArray[@]}
  do
    echo $dir >> $myfile
    cat $dir/efs.gmp.group >> $myfile
    echo ""
  done

  echo "" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo ":             Uptime              :" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo "" >> $myfile
   
  for dir in ${nodeArray[@]}
  do
    echo $dir >> $myfile
    cat $dir/uptime >> $myfile
    echo ""
  done


  echo "" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo ":       Installed Packages        :" >> $myfile
  echo ":::::::::::::::::::::::::::::::::::" >> $myfile
  echo "" >> $myfile
   
  for dir in ${nodeArray[@]}
  do
    echo ""
    echo $dir >> $myfile
    echo ""
    cat $dir/varlog.tar/log/isi_pkg | grep -i installed >> $myfile
    echo ""
  done


  #go back to main
  MAINF
}
#end health check

#list nodes
function listnodes(){
  echo "OneFS $VERSION"
  for i in ${nodeArray[@]}
  do
    echo $i
  done
  MAINF
}
#end list nodes

#load nodes
function loadnodes(){
  nodes="$(cut -d' ' -f3 nodes_info | grep -v node)"
  nodeArray=($nodes)
  VERSION="$(cut -d' ' -f4 ${nodeArray[0]}/uname)"
}
#end load nodes

#main function
function MAINF(){
echo ""
echo "What would you like to do?"
echo "1 - Search messages files"
echo "2 - Message file tails"
echo "3 - List nodes"
echo "4 - hardware scan"
echo "5 - SMB rollup patch status"
echo "6 - General cluster health"
echo "q - Quit to shell"
echo ""
read option

case "$option" in
  1)
    echo ""
    message_search
    ;;
  2)
    echo ""
    messagetails
    ;;
  3)
    echo ""
    listnodes
    ;;
  4)
    echo ""
    hwscan
    ;;
  5)
    echo ""
    rollup
    ;;
  6)
    echo ""
    healthy
    ;;
  q)
    clear
    exit 0
    ;;
  Q)
    clear
    exit 0
    ;;
  *)
    echo ""
    echo "please pick a valid option"
    echo ""
    MAINF
    ;;
esac


}
#end main

startup
