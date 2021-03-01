#!/bin/bash
trap 'rm -rf "$TMP_DIR"' EXIT;
#URL="https://github.com/Asabeneh/30-Days-Of-Python";
URL="https://github.com/mozilla/activity-stream";
#URL="https://github.com/TelegramMessenger/MTProxy/pulls";
#URL="https://github.com/nodejs/node";
REPO_NAME=$(echo "$URL" | cut -d'/' -f5);
USER_NAME=$(echo "$URL" | cut -d'/' -f4);

#Create a temp dir to store responses because they could be too large to store in memory.
PULLS_TMP_DIR=$(mktemp -d);
printf "Reading data from the repo '%s' of user '%s'...\n\r" "$REPO_NAME" "$USER_NAME";

# Init resulting varible with empty json array
payload="[]";

# curl open PR page by page, 100 per query.
for ((i=1; ; i++)); do

    response=$(curl -s -w "%{http_code}" "https://api.github.com/repos/${USER_NAME}/${REPO_NAME}/pulls?&per_page=100&page=${i}");   

    # Extract the response code 
    response_code=$(echo "$response" | tail -n1);

    # If response code is not 200, then print error message and exit the programm
    if [[ "$response_code" -ne 200 ]]; then 
        printf "Error: http response code is %s\n\r" "$response_code"
        exit 1;
    fi
    # Extract the payload and remove unnecessary staff
    data=$(echo "$response" | head -n -1 | jq  '[.[] | { u: .user | .login, s: .state, l: [.labels | map(.name)]}]');

    # If response body contains an empty array, then exit the loop
    if [[ $(echo "$data" | jq '. | length') == 0 ]]; then
        break
    fi

    # Merge current payload  with the payload from previous iteration.
    payload=$(jq -n --argjson arg1 "$payload" --argjson arg2 "$data" '$arg1 + $arg2');
done

echo "$payload" > test.json;


#open_pulls=$(echo "$payload" | jq '[.[] | select(.state == "open")]')
#printf "Found %s opened pull requests. %s in total\n\r" "$(echo "$open_pulls" | jq '. | length')" "$(echo "$payload" | jq '. | length')"

printf "Found %s opened pull requests.\n\r" "$(echo "$payload" | jq '. | length')"

printf "Most productive contributors:\n\r";
echo "$payload" | jq '.[].u' | sort | uniq -c | sort -gr -k 1 | awk 'BEGIN {printf "\tUser name\t\tOpen Pull Requests\n"}; $1 > 1 {printf "%-17s\t%16s\n", $2, $1}'