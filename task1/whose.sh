#!/bin/sh
while [ -n "$1" ]
 do
 	case "$1" in

 			-v    ) OUTPUT_DATA='^Organization|^Country';;
			-vv   ) OUTPUT_DATA='^Organization|^Country|^City';;
			-vvv  ) OUTPUT_DATA='^Organization|^Country|^City|^Addres|^PostalCode';;
 			-e    ) CONNECTIONS_DETAILS=$(sudo netstat -tnp | grep -w 'ESTABLISHED');;
            -eu   ) CONNECTIONS_DETAILS=$(sudo netstat -tunp | awk '$6 =="ESTABLISHED" || $6 == "/$^/" {print $0}');;
 			-a    ) CONNECTIONS_DETAILS=$(sudo netstat -tnap);;
			*     ) PROCESS=$1;;
 		esac
	shift;			
done

if [ ! -n "$PROCESS" ] 
 then 
   	echo "Process name or PID must be specified";
 	echo "Example of usage: 'whose.sh firefox' or 'whose.sh 1287'";
 	exit 1;
fi 	

if [ ! -n "$CONNECTIONS_DETAILS" ] 
 then CONNECTIONS_DETAILS=$(sudo netstat -tunap)
fi

if [ ! -n "$OUTPUT_DATA" ] 
 then OUTPUT_DATA='^Organization'
fi

echo "$CONNECTIONS_DETAILS" | awk -v pat="$PROCESS" '$7~pat {print $5}' | 
  cut -d: -f1 | sort | uniq -c | sort | tail -n5 | 
  grep -oP '(\d+\.){3}\d+' | 
  while read IP
   do 
   	whois $IP | 
   	awk -v pat="$OUTPUT_DATA" ' 	     
   		BEGIN {FS = ":"; patt = $PATTERN;}; 
   		$1 ~ pat {print $1, $2}';
    echo '\n';
   done