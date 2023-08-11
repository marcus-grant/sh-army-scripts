#!/bin/bash
function usage {
    echo "jq-secret-hostname-hetzner.sh"
    echo "Usage: jq-secret-hostname-hetzner"
    echo "Description:"
    echo "Uses 'secrets-json' to view JSON form of secrets file and"
    echo "with 'jq' search for the secret, $HETZNER_KEY,"
    echo "which contains the base URL to the hetzner servers' gateway."
}

HETZNER_KEY="hostname_hetzner"

function main {
    secretsJson="$(./secrets-json.sh)"
    rcSecretsJson="$?"
    if [ "$rcSecretsJson" -ne 0 ]; then
        echo "Error in calling ./secrets-json.sh"
        echo
        usage
        exit 1
    fi
    hostnameHetzner=$(echo "$secretsJson" | jq -r ".${HETZNER_KEY}")
    rcJqQuery="$?"
    if [ "$rcJqQuery" -ne 0 ]; then
        echo "Error in calling jq .${HETZNER_KEY}"
        echo
        usage
        exit 2
    fi
    echo "$hostnameHetzner"
}

main "${@}"

