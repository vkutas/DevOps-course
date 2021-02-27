#!/bin/bash
LINES=$(jq '.prices[] | [. | .[0], ((.[0] / 1000) | strftime("%m")), ((.[0] / 1000) | strftime("%y")), .[1]] | select(.[1] == "03")' quotes.json);

for YEAR in $(seq 15 20); do 
    YEAR_VAL=$(echo "$LINES" | jq --arg year "$YEAR" '. | select(.[2] == $year) | .[3]' | sort -g)
    YEAR_MIN=$(echo "$YEAR_VAL" | head -n1);
    YEAR_MAX=$(echo "$YEAR_VAL" | tail -n1);
    VOLATILITY=$(printf "%s\n\r20%s %s" "$VOLATILITY" "$YEAR" $(echo "scale=4; ($YEAR_MAX - $YEAR_MIN) / 2" | bc))
done

echo "$VOLATILITY" | sort -k2 -g | head -n2 | cut -d' ' -f1;