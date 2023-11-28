#!/bin/bash

SHALAD_CMD="pipes"
SHALAD_DIR="util/debug"

function usage {
    echo "${SHALAD_DIR}/${SHALAD_CMD}"
    echo "MODULE: util/debug"
    echo "USAGE: $SHALAD_CMD cmd [\$@]"
    echo "DESCRIPTION:"
    echo "    Debug utility to pipe stdout and stderr "
    echo "ARGUMENTS:"
    echo "    cmd   : The command to show both stdout and stderr of."
    echo "    \$@   : (OPTIONAL) Arguments to pass to the command."
    echo "RETURNCODES:"
    echo "    0: The command ran successfully."
    echo "    1: The command given can't be run."
}

function checkargs {
    if [[ "$#" -lt 1 ]]; then # Check if at least 1 argument
        echo "ERROR: Command to debug is missing!" >&2
        echo
        usage >&2
        exit 1
    fi
    if ! command -v "${1}" &> /dev/null; then # Check if command is available
        echo "ERROR: Command not found!" >&2
        echo
        usage >&2
        exit 1
    fi
    for arg in "${@:0:2}"; do # Check for -h or --help in first 2 arguments
        if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
            usage
            exit 0
        fi
    done
}

function main {
    checkargs "${@}"
    echo
    echo "Debugging Command Pipes!"
    echo "Command: $*"
    
    { # Prepare IFS for reading null-delimited output
    IFS=$'\n' read -r -d '' RESULT_STDERR;
    IFS=$'\n' read -r -d '' RESULT_STDOUT;
    } < <((printf '\0%s\0' "$("${@:1}")" 1>&2) 2>&1)

    # Figure out how to capture the return code properly
    # echo "RETURNCODE: $?"
    echo "RETURNCODE: $("${@:1}" > /dev/null 2>&1; echo $?)"
    echo "STDOUT:"
    echo
    echo "${RESULT_STDOUT}"
    echo
    echo "STDERR:"
    echo
    echo "${RESULT_STDERR}"
    echo
}

main "${@}"
