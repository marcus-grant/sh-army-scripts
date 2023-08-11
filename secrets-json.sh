#!/bin/bash
function usage {
    echo "secrets-json"
    echo "Usage: secrets-json"
    echo "Description:"
    echo "Uses 'cat' to print out the contents of the secrets.json file."
    echo "This file is located using the 'secrets/search-secrets' script."
}


function main {
    secretsJson="$(cat $(./search-secrets-file.sh))"
    _rc="$?"
    if [ $_rc -eq 0 ]; then
        echo "$secretsJson"
        exit 0
    else
        echo "Error from using cat on results of search-secrets-file.sh"
        echo
        usage
        exit 1
    fi
}

main "$@"
