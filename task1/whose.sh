#!/bin/sh
PROCESS=$1
sudo netstat -tunapl | awk -v pat="$PROCESS" '$7~pat {print $5}' | 
  cut -d: -f1 | sort | uniq -c | sort | tail -n5 | 
  grep -oP '(\d+\.){3}\d+' | 
  while read IP
   do 
   	whois $IP | awk 'BEGIN {FS = ":"}; /^Organization/ {print $2}';
   done
