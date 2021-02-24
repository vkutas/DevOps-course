## DESCRIPTION ##
This script finds network connections of processes (by process name or PID) and for each Foreign Address print information about IP address owner. 
By default its looking for all TCP and UDP connections, sort them by remote IP address and for last 5 connections returns the informations about of the organization to which the Remote Address belongs as well as count of connections per IP. By default output only contains the name of the organization and count of connection to each unique remote IP address.

In order to get more information about remote IP address owner, options -v or -vv could be used as describe below.
In order to get information about other connections states, options -e, -u, -a could be used as describe below.

If run as non-root user output only contains information about user-owned processes. If run as root user output contain information about all users processes.

## USAGE #
***./whose_v2_v2.sh PROCESS_NAME [-e] [-u] [-a] [-n NUM] [OTPUT_OPTIONS]***    
***./whose_v2_v2.sh PID [-e] [-u] [-t] [-n NUM] [-OTPUT_OPTIONS]***    

## EXAMPLE OF USAGE ##
***./whose_v2_v2.sh firefox***  
***./whose_v2_v2.sh firefox -n 10 -vv***  
***./whose_v2_v2.sh 1298 v -a -n 6***  
***./whose_v2_v2.sh 1298 -u -n 6 vvc***  

## OPTIONS ##

-e - Show information only about TCP connections in ESTABLISHED state.

-a - Show information about TCP connections in ESTABLISHED state and all UDP connections.

-t - Show information only about TCP connections in all states.

-n NUM - Specifying number of connection which will be processed by the script. By default - 5 last connections from list sorted by remote IP.

## OUTPUT OPTIONS ##

-v - Prints information about country and city where IP owner located.

-vv - In addition to '-v' prints information about organization's address and postal code.

-c - Prints information about count of connections per organizations (separate table in the of main output).

## TIPS ##
When process_name is provided, it don't have to exactly match the process name, for instance if run the script as:  
***./whose_v2_.sh fire -vv -a***  
it will find connections for all the following processes: *fire*, *firefox*, *firefox-esr*, *my-fire*, etc.

If slash sign '/' was added prior to the procces name, for instance:  
***./whose_v2.sh /fire -vv -a***  
only the following process will be match: *fire*, *firefox*, *firefox-esr*, but not *my-fire*.

To be sure you get information only about desired process use PID instead with slash sign '/' just after PID, for instance:  
***./whose_v2.sh 1182/ -vv -a*** 
this only show information about connection of process with PID 1182.
