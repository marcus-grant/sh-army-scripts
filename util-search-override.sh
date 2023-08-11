#!/bin/bash

function usage {
    echo "util-search-override.sh"
    echo "Usage: util-search-override.sh [filename] search_term1 [search_term2 ...]"
    echo "Description:"
    echo "Searches lines from piped-in data or from the given file"
    echo "for each search term provided as arguments."
    echo "Returns the last matching line if found; otherwise, an empty string."
}

function search_in_data {
    local whoami_response="$1"
    shift
    local last_matching_line=""
    
    while IFS= read -r line; do
        for term in "$@"; do
            if echo "$line" | grep -q "$term"; then
                last_matching_line="$line"
            fi
        done
    done <<< "$whoami_response"
    
    echo "$last_matching_line"
}

function main {
    if [ $# -eq 0 ]; then
        echo "Input Error: You must include at least one search term"
        echo
        usage
        exit 1
    fi
    
    if [ -p /dev/stdin ]; then
        whoami_response="$(cat -)"
    elif [ -f "$1" ]; then
        whoami_response=$(cat "$1")
        shift
    else
        echo "No data provided."
        usage
        exit 1
    fi
    
    last_matching_line=$(search_in_data "$whoami_response" "$@")
    if [ -n "$last_matching_line" ]; then
        echo "$last_matching_line"
        exit 0
    else
        exit 1
    fi
}

main "$@"

