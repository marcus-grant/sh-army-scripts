#!/bin/bash

USAGE=$(cat << 'EOF'
DESCRIPTION:
    Checks if the number of arguments given is within a specified range.
    Optionally prints a usage message, error message and
    exits with a specified exit code.

USAGE:
    util/arg/check-num.sh [low] [hi] [ex_code] [use_msg] [err_msg] -- [ags...]

ARGUMENTS:
    -h, --help  (OPTIONAL) Show this help message.
    low         The lower bound of the number of arguments to check for.
                (default: 0)
    hi          (OPTIONAL) The upper bound of the number of arguments to check for.
    ex_code     (OPTIONAL) The exit code to use if the check fails.
    use_msg     (OPTIONAL) The usage message to print if the check fails.
    err_msg     (OPTIONAL) The error message to print if the check fails.
    --          Delimiter separating control args from arg to check.
    args...     The arguments to check the number of.

RETURNCODES:
    0   The number of arguments is within the specified range.
    1   The number of arguments is not within the specified range.
    2   No '--' delimiter found in util/arg/check-num.sh!

EXAMPLES:
    Check if there are at least 2 arguments:
        util/arg/check-num.sh 2 -- "$@"
    
    Check if there's exactly 2 arguments:
        util/arg/check-num.sh 2 2 -- "$@"

    Check if there are between 2 and 4 arguments:
        util/arg/check-num.sh 2 4 -- "$@"
    
    Check if there's between 2 & 4 arguments with a custom error message:
        util/arg/check-num.sh 2 4 -- "$@" -e 1 -m "Custom error message!"

    Check if there's between 2 & 4 arguments with a custom exit code (16):
        util/arg/check-num.sh 2 4 16 -- "$@"
    
    Same as before but with custom exit code, usage message, and error message:
        util/arg/check-num.sh 2 4 16 \
            "Custom usage message!" "Custom error message!" \
            -- "$@"
EOF
)

# First check if any argument before the delimiter is -h or --help
if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
    echo "${USAGE}" # If so print usage
    exit 0
fi

# Function to check the number of arguments
LO_BOUND=$1
HI_BOUND=$2
EX_CODE=$3
USE_MSG=$4
ERR_MSG=$5

# Find the control argument '--' delimiter
for (( i=1; i<=$#; i++ )); do
    if [[ "${!i}" == "--" ]]; then
        DELIM_IDX=$i
        break
    fi
done

# Error if no delimiter found
if [[ -z "${DELIM_IDX}" ]]; then
    echo
    echo "No '--' delimiter found in util/arch/check-num.sh!" >&2
    echo
    echo "$USAGE" >&2
    exit 2
fi

# Calculate the number of arguments after the delimiter
ARG_COUNT=$(( $# - DELIM_IDX - 1))

# Check if the number of arguments is within specified bounds
# NOTE: if the bounds are equal, you're checking for a specific number of args
if [[ "${ARG_COUNT}" -lt "${LO_BOUND}" ]] || [[ -n "${HI_BOUND}" && "${ARG_COUNT}" -gt "${HI_BOUND}" ]]; then
    if [[ -n "${ERR_MSG}" ]]; then
        echo >&2
        echo "${ERR_MSG}" >&2
    fi
    if [[ -n "${USE_MSG}" ]]; then
        echo >&2
        echo "${USE_MSG}" >&2
    fi
    if [[ -n "${EX_CODE}" ]]; then
        exit "${EX_CODE}"
    else
        exit 1
    fi
fi

# If it fails to exit from the above, then the arguments pass the check
exit 0
