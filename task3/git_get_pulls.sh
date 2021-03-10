#!/bin/bash

if [ ${#@} -ne 1 ]; then
    printf "Link to the repository is not provided or not valid.\n\r";
    printf "Example of usage: %s %s\n\r" "$0" "https://github.com/curl/curl";
    exit 1;
fi

url=$1;
repo_name=$(echo "$url" | cut -d'/' -f5);
user_name=$(echo "$url" | cut -d'/' -f4);
api_pulls_url="https://api.github.com/repos/${user_name}/${repo_name}/pulls"

# Init resulting varible with empty json array
data="[]";

printf "Geting data from the repo '%s' of user '%s'...\n\r" "$repo_name" "$user_name"

# curl open PRs page by page, 100 per query.
for ((i=1; ; i++)); do

    response=$(curl -s -w "%{http_code}" "${api_pulls_url}?&per_page=100&page=${i}");
    
    # Extract the response code 
    response_code=$(echo "$response" | tail -n1);

    # If response code is not 200, then print error message and exit the programm
    if [[ "$response_code" -ne 200 ]]; then 
        printf "Error: http response code %s\n\r" "$response_code"
        exit 1;
    fi
    
    # Extract the payload 
    payload=$(echo "$response" | head -n -1)

    # If response body contains an empty array, then exit the loop
    if [[ $(echo "$payload" | jq '. | length') == 0 ]]; then
        break
    fi

    #remove unnecessary staff to make result more compact
    payload=$(echo "$payload" | jq -c '[.[] | { t: .title, u: .user.login, d: .created_at, l: .labels | map(.name), c: .comments_url }]');

    # Merge current payload  with the payload from previous iteration.
    data=$(jq -nc --argjson arg1 "$data" --argjson arg2 "$payload" '$arg1 + $arg2');
done

# If the repo has no opes PRs, print message and exit, else print number of open PRs.
# Print info message and exit

open_pulls_count="$(echo ${data} | jq '. | length')";
if [[  "$open_pulls_count" == 0 ]]; then
    printf "The repo '%s' of user '%s' has no open Pull Requests. \n\rThere is nothing to show. ¯\_(ツ)_/¯ \n\r" `
        `"$repo_name" `
        `"$user_name";
    exit 1;
fi

# Print count of open PRs
printf "\n\rFound %s open pull requests.\n\r" "${open_pulls_count}"

##############################################################################################
# Most productive contributors (i.e. contributors who has more than 1 open PR).

# Print header 
printf "\n\r%34s\n\r" "Most productive contributors";
printf "#%.0s" {1..41}
printf "\n\r%-12s\t%20s\n\r" "USER" "COUNT OF PRs"
printf "=%.0s" {1..41}

# Print the data
echo "$data" | jq '.[].u' | sort | uniq -c | sort -gr -k 1 | awk '$1 > 1 {printf "\n\r%-17s\t%-16s", $2, $1}'

##############################################################################################
# Number of PRs each contributor created and get labels of each his\her PR.

# Extract data from payload 
contributors=$(echo "$data" | jq -rc 'group_by(.u) |  .[] | {n: . | length, u: .[0].u, l: . | map(.l[]) | unique }')

# Print header
printf "\n\n\r%35s\n\r" "Open Pull Requests";
printf "#%.0s" {1..52}
printf "\n\r%-12s\t%12s\t%20s\n\r" "USER" "COUNT OF PRs" "LABELS"
printf "=%.0s" {1..52};

# Print the data
while IFS= read -r contributor; do
    printf "\n\r%-12s\t%6s\t\t%-28s" `
        `"$(echo "$contributor" | jq -r '.u')" `          
        `"$(echo "$contributor" | jq -r '.n')" `          
        `"$(echo "$contributor" | jq -r '.l | join(", ")')";  
done <<< "$contributors"

##############################################################################################
# Most discussed PRs

# Get 10 most discussed comments
response=$(curl -s -w "%{http_code}" "${api_pulls_url}?sort=popularity&direction=desc&per_page=10&page=1")

# Extract the response code 
response_code=$(echo "$response" | tail -n1);

# If response code is not 200, then print error message and exit the programm
if [[ "$response_code" -ne 200 ]]; then 
    printf "Error: http response code %s\n\r" "$response_code"
    exit 1;
fi

# Extract the required data from response 
data=$(echo "$response" | head -n -1 | jq -c '[.[] | { t: .title, u: .user.login, d: .created_at, l: .labels | map(.name)}]');

while read  pull; do   
    pop_pulls=$(printf "%s\n\r%-20s %-22s %-92s %-30s" "$pop_pulls" \
        "$(echo $pull | jq -r '.u')" \
        "$(echo $pull | jq -r '.d | .[:-1] | split("T") | join(" ")')" \
        "$(echo $pull | jq -r '.t')" \
        "$(echo $pull | jq -r '.l | join(", ")')")
done <<< "$(echo $data | jq -rc '.[]')"

# Print header
printf "\n\n\r%95s\n\r" "Most discussed Pull Requests"
printf "#%.0s" {1..170}
printf "\n\r%13s %22s %54s %65s\n\r" "AUTHOR" "CREATED AT" "PR TITLE" "PR LABELS";
printf "=%.0s" {1..170}

# Print the data
echo "$pop_pulls"
