This script finds network connections procces (process name or PID) and for each Foreing Address print information about IP owner. 
By default its looking for UDP connections and TCP connections of all states and return the name of the Organization to which the Remote Address belongs.

In order to get more information about remote IP address owner, options -v, -vv or -vvv could be used as decribe below.
In order to get information about other connections states, options -e, -eu, -a could be used as decribe below.

USAGE
 task_1.sh [OPTIONS] process_name 
 task_1.sh [OPTIONS] PID
 task_1.sh process_name [OPTIONS]  
 task_1.sh PID [OPTIONS]

 OPTIONS
 -v  
 Print inforamtion about country where IP owner located

 -vv 
 Print inforamtion about country and city where IP owner located

 -vvv 
 Print inforamtion about country,city, address and postal code where IP owner located

-e
Show information only about TCP connections in ESTABLISHED state.

-eu
Show information about TCP connections in ESTABLISHED state and all UDP connections.

-a
Show information only about TCP connections in all states.