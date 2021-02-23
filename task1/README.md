##DESCRIPTION
This script finds network connections of processes (by process name or PID) and for each Foreign Address print information about IP address owner. 
By default its looking for all TCP and UDP connections, sort them by remote IP address and for last 5 connections returns the informations about of the organization to which the Remote Address belongs as well as count of connections per organization. By default output only contains the name of the organization and count of connection to each unique remote IP address.

In order to get more information about remote IP address owner, options -v, -vv or -vvv could be used as describe below.
In order to get information about other connections states, options -e, -eu, -a could be used as describe below.

If run as non-root user output only contains information about user-owned processes. If run as root user output contain information about all users processes.

##USAGE
	whose.sh process_name [OPTIONS]  
	whose.sh PID [OPTIONS]

##TIPS
When process_name is provided, it don't have to exactly match the process name, for instance if run the script as: 
	./whose.sh fire -vv -a 
it will find connections for all the following processes: fire, firefox, firefox-esr, my-fire, etc.
If slash sign '/' was added prior to the procces_name argument, for instance 
	./whose.sh /fire -vv -a 
only the following process will be match: 'fire', 'firefox', 'firefox-esr', but not 'my-fire', 
To be sure you get information only about desired process use PID instead with slash sign '/' just after PID, for instance:
	./whose.sh 1182/ -vv -a 
this only show information about connection of process with PID 1182.

##OPTIONS
-v  
	Print information about country where IP owner located
-vv 
	Print information about country and city where IP owner located

-vvv 
	Print information about country,city, address and postal code where IP owner located

-e
	Show information only about TCP connections in ESTABLISHED state.

-eu
	Show information about TCP connections in ESTABLISHED state and all UDP connections.

-a
	Show information only about TCP connections in all states.

-n NUM
	Specifying number of connection which will be processed by the script. By default - 5 last connections from list sorted by remote IP.