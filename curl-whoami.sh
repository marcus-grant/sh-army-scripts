#!/bin/bash

function usage {
    echo "whoami-internet.sh"
    echo "Usage: whoami-internet.sh [endpoint_url]"
    echo "Description:"
    echo "Fetches the response from the given endpoint URL using curl."
    echo "If no endpoint URL is provided, it uses the hostname from"
    echo "secrets.json.hetzner_hostname using 'jq'."
}

# Get the hostname using jq-secret-hostname-hetzner.sh
function get_hostname {
    hostname=$(./jq-secret-hostname-hetzner.sh)
    if [ $? -ne 0 ]; then
        echo "Error in calling jq-secret-hostname-hetzner.sh"
        exit 1
    fi
    echo "$hostname"
}

# Fetch and display the response from the given endpoint
function fetch_endpoint {
    endpoint_url="$1"
    response=$(curl -s "$endpoint_url")
    echo $endpoint_url
    if [ $? -ne 0 ]; then
        echo "Error in fetching the response from $endpoint_url"
        exit 2 
    fi
    echo "Response from $endpoint_url:"
    echo "$response"
}

main() {
    if [ $# -eq 0 ]; then
        hostname="$(get_hostname)"
        endpoint_url="https://whoami.${hostname}/"
    else
        endpoint_url="$1"
    fi

    fetch_endpoint "$endpoint_url"
}

main "$@"

