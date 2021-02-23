#!/bin/sh
export PATH="/usr/local/bin:/usr/bin";
EXAMPLE_OF_USAGE="Example of usage: 'whose_v2.sh firefox' or 'whose_v2.sh 1287'. \nSee README_v2.md for more details.\n";
PROCESS="$1";
shift;

while [ -n "${1}" ]; do
 	case "$1" in

 			-v    ) OUTPUT_DATA='/Organization\|Country/p'; n=2;;
			-vv   ) OUTPUT_DATA='/Organization\|Country\|City/p'; n=3;;
			-vvv  ) OUTPUT_DATA='/Organization\|Country\|City\|Address\|PostalCode/p';;
 			-e    ) CONNECTIONS_DETAILS=$(netstat -tnp | grep -w 'ESTABLISHED');;
      -eu   ) CONNECTIONS_DETAILS=$(netstat -tunp | awk '$6 =="ESTABLISHED" || $1 == "udp" {print $0}');;
 			-a    ) CONNECTIONS_DETAILS=$(netstat -tnap);;
			-n    ) NUMBER_OF_CONNECTIONS="$2";
					    shift;
              ;;
			*     ) echo "Option ${1} is unknown";
              echo "$EXAMPLE_OF_USAGE";
              exit 1;
              ;;
 		esac
	shift;			
done

if [ ! -n "${PROCESS}" ]; then 
   	printf "Process name or PID must be specified\n${EXAMPLE_OF_USAGE}";
 	  printf "$EXAMPLE_OF_USAGE";
 	exit 1;
fi 	

if [ ! -n "${CONNECTIONS_DETAILS}" ]; then 
	CONNECTIONS_DETAILS=$(netstat -tunap)
fi

if [ ! -n "${OUTPUT_DATA}" ]; then 
	OUTPUT_DATA='/Organization/p'
fi

if [ ! -n "${NUMBER_OF_CONNECTIONS}" ]; then 
	NUMBER_OF_CONNECTIONS=5
fi

PROCESS_CONNECTIONS=$(echo "${CONNECTIONS_DETAILS}" | awk -v pat="$PROCESS" '$7~pat {print $5}');
if [ ! -n "${PROCESS_CONNECTIONS}" ]; then 
	echo "Connections for process \"${PROCESS}\" not found.";
  echo "$EXAMPLE_OF_USAGE";
	exit 1;
fi

echo "${PROCESS_CONNECTIONS}" | cut -d: -f1 | sort | uniq -c | sort | tail -n"${NUMBER_OF_CONNECTIONS}" | 
  while read ADDRES_LINE; do 
   	CON_PER_IP=$(echo "$ADDRES_LINE" | cut -d' ' -f1);
   	IP=$(echo "$ADDRES_LINE" | cut -d' ' -f2);
   	DATA=$(whois "$IP" | sed -n $OUTPUT_DATA | tail -"$n");
   	echo "Remote IP Address: ${IP}";
   	echo "Number of Connections ${CON_PER_IP}"
    echo "$DATA";
    echo;
   done