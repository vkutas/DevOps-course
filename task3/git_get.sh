#!/bin/bash

if [ ${#@} -ne 1 ]; then
    printf "Link to the repository is not provided or not valid.\n\r";
    printf "Example of usage: %s %s\n\r" "$0" "https://github.com/curl/curl";
    exit 1;
fi

url=$1;
repo_name=$(echo "$url" | cut -d'/' -f5);
user_name=$(echo "$url" | cut -d'/' -f4);

echo "DEBUG: $repo_name"
echo "DEBUG: $user_name"

# Init resulting varible with empty json array
payload="[]";

printf "Geting data from the repo '%s' of user '%s'..." "$repo_name" "$user_name"

# curl open PR page by page, 100 per query.
for ((i=1; ; i++)); do

    response=$(curl -s -w "%{http_code}" "https://api.github.com/repos/${user_name}/${repo_name}/pulls?&per_page=100&page=${i}");   

    # Extract the response code 
    response_code=$(echo "$response" | tail -n1);

    # If response code is not 200, then print error message and exit the programm
    if [[ "$response_code" -ne 200 ]]; then 
        printf "Error: http response code is %s\n\r" "$response_code"
        exit 1;
    fi
    # Extract the payload and remove unnecessary staff to make it more compact
    data=$(echo "$response" | head -n -1 | jq -c '[.[] | { u: .user | .login, l: [.labels | map(.name)]}]');

    # If response body contains an empty array, then exit the loop
    if [[ $(echo "$data" | jq '. | length') == 0 ]]; then
        break
    fi

    # Merge current payload  with the payload from previous iteration.
    payload=$(jq -nc --argjson arg1 "$payload" --argjson arg2 "$data" '$arg1 + $arg2');
done

echo "$payload" > test.json;

printf "Found %s opened pull requests.\n\r" "$(echo "$payload" | jq '. | length')"

printf "Most productive contributors:\n\r";
echo "$payload" | jq '.[].u' | sort | uniq -c | sort -gr -k 1 | awk 'BEGIN {printf "\tUser name\t\tOpen Pull Requests\n"}; $1 > 1 {printf "%-17s\t%16s\n", $2, $1}'