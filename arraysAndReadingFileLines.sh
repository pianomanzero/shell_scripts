#!/bin/bash
INFILE=$1
old_IFS=$IFS
IFS=$'\n'
lines=($(cat $(echo $INFILE))) # should go into an array called lines
IFS=$old_IFS

echo "Line 4: ${lines[4]}"
echo "Line 10: ${lines[10]}"
echo "The lines array has this many elements"
echo ${#lines[@]}
exit 0
