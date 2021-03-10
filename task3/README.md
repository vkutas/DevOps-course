This script take a link to an user GitHub repository and get various info about the repository's open Pull Requests, such as:
1. Number of Pull Requests.
2. Most productive contributors (i.e. contributors who has more than 1 open PR).
3. Number of Pull Requests of each contributor with labels of all his/her commits.
3. Top 10 most discussed Pull Requests.

It uses [**curl**](https://github.com/curl/curl) to query the API and [**jq**](https://stedolan.github.io/jq/) to parse the data. 
Script query the data page by page (100 Pull Requests per page) until empty page is returned and then process them. So. if the repo you pass as argument has 80 open 
Pull Requests, it issue 3 requst to the API, one for first page (PRs from 1 to 80), empty page which shows that the data ends and last requst to get most popular Pull Requests. 

#### USAGE ####

    ./git_get_pulls.sh LINK_TO_REPOSITORY
    ./git_get_pulls.sh LINK_TO_REPOSITORY -u AUTH_USERNAME -t AUTH_TOKEN

### Authentication ###
The script support authentication with [GitHub personal token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token). If you don't provide the username and token You will be limited to 60 requests per hour. 

#### NOTE ####
This script works only with open Pull Requests only.
Also note that GitHub limit API requests to 60 per hour from IP for unauthenticated clients. 


#### EXAMPLE OF USAGE ####

     ./git_get_pulls.sh https://github.com/curl/curl
     ./git_get_pulls.sh https://github.com/vkutas/DevOps-home-tasks
     ./git_get_pulls.sh https://github.com/vkutas/DevOps-home-tasks -u znak -t sdfs4ghklkj23sdf23424fvdfv3g541dsf

#### EXAMPLE OF OUTPUT ####

<pre> 
./git_get_pulls.sh https://github.com/curl/curl
Geting data from the repo 'curl' of user 'curl'...
Found 23 open pull requests.

      Most productive contributors
#########################################
USER                    COUNT OF PRs
=========================================
"jay"                   5               
"monnerat"              3               
"mkolechkin"            2               
"mback2k"               2               
"gvollant"              2               

                 Open Pull Requests
####################################################
USER            COUNT OF PRs                  LABELS
====================================================
KAction              1          needs-info-or-update        
MAntoniak            1                                      
bachue               1          HTTP/3                      
duelle               1          CI                          
gvollant             2          SSL/TLS                     
jay                  5          CI, HTTP/3, SSL/TLS, Windows, build, cmdline tool, connecting & proxies, name lookup, tests
mback2k              2          SMB, Windows                
mickae1              1          SCP/SFTP, needs-info-or-update
mkauf                1          SSL/TLS, feature-request    
mkolechkin           2          SSL/TLS                     
monnerat             3          SSL/TLS, tests, tidy-up     
simo5                1          authentication              
vszakats             1                                      
wrowe                1          Windows, cmake, needs-info-or-update

                                                                   Most discussed Pull Requests
##########################################################################################################################################################################
       AUTHOR             CREATED AT                                               PR TITLE                                                         PR LABELS
==========================================================================================================================================================================
gvollant             2020-10-21 08:29:21    support CAfile in memory                                                                     SSL/TLS                       
simo5                2020-03-27 17:34:19    Add support for using GSSNTLMSSP module for NTLM and channel bindings                        authentication                
mback2k              2020-11-24 21:11:31    multi: implement waiting and wakeup using winsock events                                     Windows                       
wrowe                2020-10-07 19:47:43    Correct fragile windows CMake assumptions                                                    Windows, cmake, needs-info-or-update
vszakats             2021-02-18 19:05:24    hsts: enable by default                                                                                                    
mickae1              2020-10-06 15:34:40    CURL_LOCK_DATA_KNOWNHOSTS                                                                    SCP/SFTP, needs-info-or-update
monnerat             2021-02-06 15:25:42    os400: additional support for options metadata                                                                             
monnerat             2021-02-24 14:05:20    Factor base64 conversions out of authentication procedures                                                                 
mkolechkin           2021-01-15 21:48:58    lib/vtls/sectransp.c: Specify cipher name for Mac Secure Transport back-end                  SSL/TLS                       
KAction              2020-11-28 16:42:49    New protocol: gemini                                                                         needs-info-or-update    
</pre>
