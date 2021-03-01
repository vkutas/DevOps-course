#!/bin/bash

if [ ${#@} -ne 1 ]; then
    printf "Link to the repository is not provided or not valid.\n\r";
    printf "Example of usage: %s %s\n\r" "$0" "https://github.com/curl/curl";
    exit 1;
fi

url=$1;
repo_name=$(echo "$url" | cut -d'/' -f5);
user_name=$(echo "$url" | cut -d'/' -f4);

# Init resulting varible with empty json array
payload="[]";

printf "Geting data from the repo '%s' of user '%s'...\n\r" "$repo_name" "$user_name"

# curl open PR page by page, 100 per query.
for ((i=1; ; i++)); do

    response=$(curl -s -w "%{http_code}" "https://api.github.com/repos/${user_name}/${repo_name}/pulls?&per_page=100&page=${i}");   

    # Extract the response code 
    response_code=$(echo "$response" | tail -n1);

    # If response code is not 200, then print error message and exit the programm
    if [[ "$response_code" -ne 200 ]]; then 
        printf "Error: http response code %s\n\r" "$response_code"
        exit 1;
    fi
    # Extract the payload and remove unnecessary staff to make it more compact
    data=$(echo "$response" | head -n -1 | jq -c '[.[] | { u: .user | .login, l: .labels | map(.name)}]');

    # If response body contains an empty array, then exit the loop
    if [[ $(echo "$data" | jq '. | length') == 0 ]]; then
        break
    fi

    # Merge current payload  with the payload from previous iteration.
    payload=$(jq -nc --argjson arg1 "$payload" --argjson arg2 "$data" '$arg1 + $arg2');
done

echo "$payload" > test.json;

printf "...\n\rFound %s opened pull requests.\n\r" "$(echo "$payload" | jq '. | length')"

printf "\n\r%34s\n\r" "Most productive contributors";
printf "#%.0s" {1..41}
printf "\n\r%-12s\t%20s\n\r" "USER" "COUNT OF PRs"
printf "=%.0s" {1..41}
echo "$payload" | jq '.[].u' | sort | uniq -c | sort -gr -k 1 | awk '$1 > 1 {printf "\n\r%-17s\t%16s", $2, $1}'


contributors=$(echo "$payload" | jq -rc 'group_by(.u) |  .[] | {c: . | length, usr: .[0].u, lbls: . | map(.l[]) | unique }')

printf "\n\r%35s\n\r" "Open Pull Requests";
printf "#%.0s" {1..52}
printf "\n\r%-12s\t%12s\t%20s\n\r" "USER" "COUNT OF PRs" "LABELS"
printf "=%.0s" {1..52};
while IFS= read -r contributor; do
    printf "\n\r%-12s\t%6s\t\t%-28s" \
        "$(echo "$contributor" | jq -r '.usr')" \
        "$(echo "$contributor" | jq -r '.c')" \
        "$(echo "$contributor" | jq -r '.lbls | join(", ")')";
done <<< "$contributors"
echo