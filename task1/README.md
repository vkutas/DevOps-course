This script finds active network connections of passed procces (process name or PID) and for each Foreing Address print information about IP owner. 
By default output only contains the name of the organization to which the IP belongs. In order to get more information use -v, -vv or -vvv. 

USAGE
 task_1.sh process_name [OPTIONS]
	OR
 task_1.sh PID	[OPTIONS]

 OPTIONS
 -v  
 Print inforamtion about country where IP owner located

 -vv 
 Print inforamtion about country and city where IP owner located

 -vvv 
 Print inforamtion about country,city, address and postal code where IP owner located