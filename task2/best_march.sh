#!/bin/bash
help_message=$(printf "Usage: %s MONTH_NUMBER START_YEAR END_YEAR\n\rExample of usage: %s 3 15 18" "$0" "$0");

# If '-h' the first parameter - print help end exit.
if [ $1 == "-h" ]; then 
    echo "Print the year in MONTH_NUMBER of which EUR/RUB price was the least volatile."
    echo "$help_message"
    exit 1;
fi

# If less than 3 arguments was passed, print error message and example of usage, then exit.
if [[ "$#" -ne 3 ]]; then
    printf "Requred arguments not found.\n\r"
    echo "$help_message"
    exit 1;
fi

# Function to check input arguments.
# Usage: check_arg A B C
# Where: A- argument to check, B - regex, to check argument with, 
#  C - argument name or role for informative error message
check_arg() {
    if [[ ! $1 =~ $2 ]]; then 
        printf "%s is invalid %s. \n\r" "$1" "$3"
        echo "$help_message"
        exit 1;
    fi  
}

# Check MONTH argument
check_arg $1 "^[1-9]$|^1[0-2]$" "month"
month=$1;
shift

# Check START_YEAR and END_YEAR arguments
for arg in "$@"; do
    check_arg $arg "^1[5-9]$|^[2-9][0-9]$" "year"
done

# If START_YEAR greater than END_YEAR, print error message and exit.
if [ $1 -gt $2 ]; then
    printf "START_YEAR can not be greater than END_YEAR"
    echo "$help_message"
    exit 1;
fi

start_year=$1
end_year=$2

# If the end month and year greater than the current,  print error message ans exit.
if [ $(date +%y) -le $end_year ] && [ $(date +%m) -le $month ];then
    printf "There is no data for the period from 01.%s.%s to 01.%s.%s.\n\rTry to use another MONTH_NUMBER or another END_YEAR.\n\r" "$month" "$start_year" "$month" "$end_year"
    echo "$help_message"
    exit 1
fi    

# Use local copy of ./quotes.json because Yandex can block your IP if you run the script often.
# If you need to update the data, just uncomment this line
#curl -s https://yandex.ru/news/quotes/graph_2000.json > ./quotes.json

# Extract required data from ./quotes.json file.
# As a rusult we'll get a list of JSON arrays of the following format:
#  [timestamp_in_miliseconds, month_number, year_number in short format, EUR/RUB price]
# Such as: [ 1523998196000, "04", "18", 76.13]
rates=$(jq --argjson m "$month" '.prices[] | [. | .[0], ((.[0] / 1000) | strftime("%m")), ((.[0] / 1000) | strftime("%y")), .[1]] | 
        select(.[1] | tonumber == $m )' ./quotes.json);


# Calculate volatile for each year from start_year to end_year.
for year in $(seq $start_year $end_year); do 
   
    year_val=$(echo "$rates" | jq --arg year "$year" '. | select(.[2] == $year) | .[3]' | sort -g)
    year_min=$(echo "$year_val" | head -n1);
    year_max=$(echo "$year_val" | tail -n1);
    valatility=$(printf "%s\n\r20%s \t%10s" "$valatility" "$year" "$(echo "scale=3; ($year_max - $year_min) / 2" | bc -lq)")
   
done

# Sort result list to find the least volotile year.
least_volatile_year=$(echo "$valatility" | sort -k2 -n | head -n2)

#Output the result
month_name=$(date -d "${month}/01" +%B)
year=$(echo $least_volatile_year | cut -d' ' -f1)
value=$(echo $least_volatile_year | cut -d' ' -f2)

printf "The least volatile %s for the period from 01.%s.20%s to 01.%s.20%s was in %s with value of: %s \n\n\r" "$month_name" "$month" "$start_year" "$month" "$end_year" "${year:1:4}" "$value"
printf "YEAR\tEUR/RUB VALATILITY"
echo "$valatility" 