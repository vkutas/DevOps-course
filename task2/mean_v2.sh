#!/bin/sh
jq -r '.prices[][1]' quotes.json | tail -n 14 | awk -v mean=0 '{mean+=$1} END {print mean/14}'