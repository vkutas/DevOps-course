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
# curl data page by page.
for ((i=1; i<=2; i++)); do
    # Temp file to store response.
    PAGE_TMP=$(mktemp -p "$PULLS_TMP_DIR" -t "tmp.pulls.XXXXXX.${i}")

    # Get http response code to catch errors.
    RESPONSE_CODE=$(curl -s -w "%{http_code}" -o "$PAGE_TMP" "https://api.github.com/repos/${USER_NAME}/${REPO_NAME}/pulls?state=all&per_page=100&page=${i}");

    if [[ "$RESPONSE_CODE" -eq 200 ]]; then
        # echo "DEBUG: ${RESPONSE_CODE}";
        # If response contains empty array json, then data is over.
        if [[ $(cat "$PAGE_TMP" | jq '. | length') == 0 ]]; then
            break;
        fi
        # If response code is not '200', then print error message and exit.
    else
        echo "The error occur when loading data: Response code: ${RESPONSE_CODE}";
        exit 1;
    fi
done

# Merge all received pages in a single json array.
PULLS=$(jq -s '. | add'  "${PULLS_TMP_DIR}"/tmp.pulls.*);

open_pulls=$(echo "$PULLS" | jq '[.[] | select(.state == "open")]')
open_pulls_count=$(echo "$open_pulls" | jq '. | length')
printf "Found %s opened pull requests.\n\r" "$open_pulls_count"

printf "Most productive contributors:\n\r";
echo "$open_pulls" | jq '.[].user.login' | sort | uniq -c | sort -r -k 1 | awk 'BEGIN {printf "  User name  \tOpen Pull Requests\n"}; $1 > 1 {printf "%-12s\t\t%-12s\n", $2, $1}'