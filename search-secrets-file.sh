#!/bin/bash
function usage {
    echo "search-secrets-file"
    echo "Usage: search-secrets-file"
    echo "Description:"
    echo "This utility searches the below paths in-order for a secrets JSON file."
    echo "The next search path overrides the previous IF it exists."
    echo "Therefore, the lowest path in this list will override any before it."
    echo "If no paths exist, you get this usage message."
    echo "Ordered Search Paths:"
    echo "- \$HOME/.secrets.json"
    echo "- \$HOME/.config/secrets.json"
    echo "- \$HOME/.config/secrets/secrets.json"
    echo "- \$HOME/.config/secrets/util/secrets.json"
    echo "- \$SECRETS_DIR/.secrets.json"
    echo "- \$SECRETS_DIR/secrets.json"
    echo "- \$SECRETS_DIR/util/secrets.json"
}

function check-secrets-file {
    if [[ ! -f "${SECRETS_FILE}" ]] || [[ -f "${1}" ]]; then
        SECRETS_FILE="${1}"
    fi
}

function main {
    # First search path
    SECRETS_FILE="${HOME}/.secrets.json"
    check-secrets-file "${HOME}/.config/secrets.json"
    check-secrets-file "${HOME}/.config/secrets/secrets.json"
    check-secrets-file "${HOME}/.config/secrets/util/secrets.json"
    check-secrets-file "${SECRETS_DIR}/secrets.json"
    check-secrets-file "${SECRETS_DIR}/util/secrets.json"
    if [ ! -f "${SECRETS_FILE}" ]; then
        echo "Secrets file not found!"
        echo
        usage
        exit 1
    fi
    echo $SECRETS_FILE
    exit 0
}

main "${@}"
