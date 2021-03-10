#!/bin/bash
EXAMPLE_OF_USAGE="Example of usage: 'whose_v2.sh firefox' or 'whose_v2.sh 1287'. See README_v2.md for more details.";
PROCESS="$1";
shift;
CL_FLAGS="$*";
while [ -n "${1}" ]; do
    case "$1" in
        -e    ) CONNECTIONS_DETAILS=$(netstat -tnp | grep -w 'ESTABLISHED');;
        -u    ) CONNECTIONS_DETAILS=$(netstat -tunp | awk '$6 =="ESTABLISHED" || $1 == "udp" { print $0 }');;
        -a    ) CONNECTIONS_DETAILS=$(netstat -tnap);;
        -n    ) NUMBER_OF_CONNECTIONS="$2";
        shift;;
        *     ) ;;
    esac
    shift;
done

if [ -z "${PROCESS}" ]; then
    printf "Process name or PID must be specified\n\r%s\n\r" "${EXAMPLE_OF_USAGE}";
    exit 0;
fi

if [ -z "${CONNECTIONS_DETAILS}" ]; then
    CONNECTIONS_DETAILS=$(netstat -tunap)
fi

if [ -z "${OUTPUT_DATA}" ]; then
    OUTPUT_DATA='^Organization'
fi

if [ -z "${NUMBER_OF_CONNECTIONS}" ]; then
    NUMBER_OF_CONNECTIONS=5
fi

PROCESS_CONNECTIONS=$(echo "${CONNECTIONS_DETAILS}" | awk -v pat="$PROCESS" '$7~pat { print $5 }');
if [ -z "${PROCESS_CONNECTIONS}" ]; then
    printf "Connections for process \"%s\" not found.\n\r" "${PROCESS}";
    exit 1;
fi

LINES=$(echo "${PROCESS_CONNECTIONS}" | cut -d: -f1 | sort | uniq -c | sort | tail -n"${NUMBER_OF_CONNECTIONS}");
while read -r LINE; do
    CON_PER_IP=$(echo "$LINE" | cut -d' ' -f1);
    IP=$(echo "$LINE" | cut -d' ' -f2);
    DATA=$(whois "$IP");
    ORGANIZATION=$(echo "$DATA" | sed -n '/^OrgName:\|^org-name:/p' | tail -1 | sed 's/^OrgName:\s*//g; s/^org-name:\s*//g');
    if [ -z "${ORGANIZATION}" ]; then
        ORGANIZATION="(Not Found)";
    fi
    OUTPUT=$(printf "%s\n%-21s %s" "${OUTPUT}" "Remote IP:" "${IP}");
    OUTPUT=$(printf "%s\n%-21s %s" "${OUTPUT}" "Count of Connections:" "${CON_PER_IP}");
    OUTPUT=$(printf "%s\n%-21s %s" "${OUTPUT}" "Organization:" "${ORGANIZATION}");
    
    # If 'v' is pasted as option, add Country and City to the output.
    if test "$(echo "$CL_FLAGS "| grep 'v')"; then
        COUNTRY=$(echo "$DATA" | sed -n '/^Country\|^country:/p' | tail -1 | sed 's/^Country:\s*//g; s/^country:\s*//g');
        if [ -z "${COUNTRY}" ]; then
            COUNTRY="(Not Found)";
        fi
        OUTPUT=$(printf "%s\n%-21s %s" "${OUTPUT}" "Country:" "${COUNTRY}");
        
        CITY=$(echo "$DATA" | sed -n '/^City:\|^city:/p' | tail -1 | sed 's/^City:\s*//g; s/^city:\s*//g' );
        if [ -z "${CITY}" ]; then
            CITY="(Not Found)";
        fi
        OUTPUT=$(printf "%s\n%-21s %s" "${OUTPUT}" "City:" "${CITY}");
    fi
    
    # If 'vv' is passed as option, add Address and Postal Code to the output.
    if test "$(echo "$CL_FLAGS "| grep 'vv')"; then
        ADDRESS=$(echo "$DATA" | sed -n '/^Address:\|^address:/p' | tail -2 | sed 's/^Address:\s*//g; s/^address:\s*//g');
        # If Address contains two or more lines, concatenate them
        if [ "$(echo "$ADDRESS" | wc -l)" -ge 2 ]; then
            ADDRESS="$(echo "$ADDRESS" | paste -sd ',')";
        fi
        if [ -z "${ADDRESS}" ]; then
            ADDRESS="(Not Found)";
        fi
        OUTPUT=$(printf "%s\n%-21s %s" "${OUTPUT}" "Address:" "${ADDRESS}");
        
        POSTAL_CODE=$(echo "$DATA" | sed -n '/^PostalCode:\|^postal-code:/p' | tail -1 | sed 's/^PostalCode:\s*//g; s/^postal-code:\s*//g');
        if [ -z "${POSTAL_CODE}" ]; then
            POSTAL_CODE="(Not Found)";
        fi
        OUTPUT=$(printf "%s\n%-21s %s" "${OUTPUT}" "PostalCode:" "${POSTAL_CODE}");
    fi
    
    OUTPUT=$(printf "%s\n\r" "${OUTPUT}");
done < <(echo "${LINES}")

printf "%s" "${OUTPUT}";

if test "$(echo "$CL_FLAGS" | grep 'c')"; then
    printf "\n#Connections per Organization#\n\r"
    echo "$OUTPUT" | sed -n '/^Organization:/p' | sed 's/^Organization:\s*//g' | sort | uniq -c | sort |
    awk 'BEGIN {printf "%-20s %s\n", "Count of connections", "Organization" }
    { printf "%-20s %s\n", $1, substr($0, index($0, $2)) }';
fi