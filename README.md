# DevOps-home-tasks #
  

## Task 1 ##
The directory **task1** contains two implementations of task 1, Scripting Homework.    
  
These scripts finds network connections of processes (by process name or PID) and for each Foreign Address print information about IP address owner. 
By default they looking for all TCP and UDP connections, sort them by remote IP address and for last 5 connections returns the informations about of the organization to which the Remote Address belongs as well as count of connections per organization.   
  
More details in ***README*** file for each implementations.  
 
 
## Task 2 ##
The directory "task2" contains implementations of task 2, Scripting Homework related to working with **jq** and contains 4 files:  
1. ***mean_origin.sh*** - Original script from the task.  
2. ***mean_v2.sh*** - Version of original script without using *grep* and *pattern matching*.  
3. ***quotes.json*** -  Historical quotes for EUR/RUB pair since late November 2014:
4. ***best_march.sh*** - Final part of task. This script read the  ***quotes.json*** and find the year which March the price was the least volatile since 2015.

More details in ***task2/README.md***. 

## Task 3 ##
Task 3 related to working with GitHub REST API from linux shell. It contains only one script - [***git_get_pulls.sh***](task3/git_get_pulls.sh).   
This script take a link to an user GitHub repository and get various info about the repository's open Pull Requests, such as:
1. Number of Pull Requests.
2. Most productive contributors (i.e. contributors who has more than 1 open PR).
3. Number of Pull Requests of each contributor with labels of all his/her commits.
3. Top 10 most discussed Pull Requests.

It uses [**curl**](https://github.com/curl/curl) to query the API and [**jq**](https://stedolan.github.io/jq/) to parse the data. 
Script query the data page by page (100 Pull Requests per page) until empty page is returned and then process them. So. if the repo you pass as argument has 80 open 
Pull Requests, it issue 3 requst to the API, one for first page (PRs from 1 to 80), empty page which shows that the data ends and last requst to get most popular Pull Requests. 

#### USAGE ####

    ./git_get_pulls.sh [LINK_TO_REPOSITORY]

#### EXAMPLE OF USAGE ####

     ./git_get_pulls.sh https://github.com/curl/curl
     ./git_get_pulls.sh https://github.com/vkutas/DevOps-home-tasks

#### NOTE ####
This script works only with open Pull Requests only.
Also note that GitHub limit API requests to 60 per hour from IP for unauthenticated clients. 