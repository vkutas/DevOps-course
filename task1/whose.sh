#!/bin/sh
if [ ! -n "$1" ]
 then 
 	echo "Process name or PID must be specified";
 	echo "Example of usage: 'whose.sh firefox' or 'whose.sh 1287'";
 	exit 1;
fi 	
case "$2" in
	-v)   OUTPUT_PATTERN='Organization|^Country';;
	-vv)  OUTPUT_PATTERN='Organization|^Country|^City';;
    -vvv) OUTPUT_PATTERN='Organization|^Country|^City|^Addres|^PostalCode';;
    *)    OUTPUT_PATTERN='^Organization';;
esac
  PROCESS=$1
sudo netstat -tunapl | awk -v pat="$PROCESS" '$7~pat {print $5}' | 
  cut -d: -f1 | sort | uniq -c | sort | tail -n5 | 
  grep -oP '(\d+\.){3}\d+' | 
  while read IP
   do 
   	whois $IP | 
   	awk -v pat="$OUTPUT_PATTERN" ' 	     
   		BEGIN {FS = ":"; patt = $PATTERN;}; 
   		$1 ~ pat {print $1, $2}';
    echo '\n';
   done