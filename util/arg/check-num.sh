#!/bin/bash
USAGE=$(cat << 'EOF'
USAGE:
    util/arg/check-num.sh \\
        [-h|--help] [-D|--debug] [-m|--min min] [-M|--max max] \\
        [-r|--return ret] [-u|--usage usage] [-e|--error error] \\
        -- [args...]

DESCRIPTION:
    Checks if the number of arguments given past the -- delimiter is within
    the specified range.
    The goal of this script is to reduce the amount of
    boilerplate of calling scripts to check the number of arguments,
    and to provide a consistent interface for doing so.
    When used this script can cut down on code needed to:
        * Check the number of arguments given to a script.
        * Print a usage message if the number of arguments is incorrect.
        * Print an error message if the number of arguments is incorrect.
        * Exit with a custom exit code if the number of arguments is incorrect.
    NOTE: To check for an exact number of arguments,
        set the min and max to the same value.

ARGUMENTS:
    -h, --help          Show this help message.
    -d, --debug         Show debug messages.
    -m, --min   min     Check that the number of args past "--" is at least
                            min number of arguments (default: 0)
    -M, --max   max     Check that the number of args past "--" is at most
                            max number of arguments (default: $#)
    -r, --return ret    If the check fails,
                            exit with the given return code. (default: 1)
    -u, --usage usage   If the check fails,
                            print the usage message in usage. (default: "")
    -e, --error error   If the check fails,
                            given message in error before usage. (default: "")
    --                  (REQUIRED) Delimiter separating control arguments from
                            another set of arguments to check the number of.
    args...             The arguments to check the number of.

RETURNCODES:
    0   The number of arguments is within the specified range.
    1   The number of arguments is not within the specified range.
    2   No -- delimiter found in util/arg/check-num.sh!
    3   Invalid control argument given for util/arg/check-num.sh!

EXAMPLES:
    Check if there are at least 2 arguments:
        util/arg/check-num.sh -m 2 -- "$@"
    
    Check if theres exactly 2 arguments:
        util/arg/check-num.sh -m 2 -M 2 -- "$@"

    Check if there are between 2 and 4 arguments:
        util/arg/check-num.sh -m 2 -M 4 -- "$@"
    
    Check if theres between 2 & 4 arguments with a custom error message:
        util/arg/check-num.sh -m 2 -M 4 -e "ERROR!" -- "$@"

    Check if theres at least 1 arg with a custom exit code:
        util/arg/check-num.sh -m 1 -r 16 -- "$@"
    
    Check if between 2~4 args with custom everything:
        util/arg/check-num.sh -m 2 -M 4 -r 16 \
            -u "Custom usage message!" -e "Custom error message!" \
            -- "$@"
EOF
)

# Check for -h or --help in arguments, print usage if so
for (( i=1; i<=$#; i++ )); do
    arg=${!i}
    if [[ "${arg}" == "-h" ]] || [[ "${arg}" == "--help" ]]; then
        echo
        echo "$USAGE"
        exit 0
    fi
    if [[ "${arg}" == "--" ]]; then
        break
    fi
done

# Check for -- delimiter in arguments, print error if not found
delim_idx=0
for (( i=1; i<=$#; i++ )); do
    arg=${!i}
    if [[ "${arg}" == "--" ]]; then
        delim_idx=$i
        break
    fi
done
if [[ "${delim_idx}" -eq 0 ]]; then
    echo
    echo "No '--' delimiter found in util/arg/check-num.sh!" >&2
    echo
    echo "$USAGE" >&2
    exit 2
fi

# Default values for control arguments
min=0
max=$#
ret=1
usage_msg=""
error_msg=""
debug="false"

# Check for control arguments and override defaults if found
while [[ $# -gt 0 ]]; do
    case $1 in
        -D|--debug)
            debug="true"
            ;;
        -u|--usage)
            shift
            usage_msg=$1
            ;;
        -m|--min)
            shift
            min=$1
            ;;
        -M|--max)
            shift
            max=$1
            ;;
        -r|--return)
            shift
            ret=$1
            ;;
        -e|--error)
            shift
            error_msg=$1
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid argument: $1"
            echo
            echo "$USAGE"
            exit 3 
            ;;
    esac
    shift
done
shift # Shift again to skip the command name which is always the first arg

# DEBUG: Debug the potentially overridden control arguments
if [[ "${debug}" == "true" ]]; then
    echo "min: ${min}"
    echo "max: ${max}"
    echo "ret: ${ret}"
    echo "usage_msg: ${usage_msg}"
    echo "error_msg: ${error_msg}"
    echo "args: ${*}"
    echo "delim_idx: ${delim_idx}"
    echo "\$#: $#"
fi

# Now that we have the control arguments,
# check the number of arguments past the -- delimiter against min and max
if [[ $# -lt "${min}" ]] || [[ $# -gt "${max}" ]]; then
    # If not within bounds it's time to start printing messages
    
    if [[ -n "${error_msg}" ]]; then # Print error message if one is given
        echo >&2
        echo "${error_msg}" >&2
    fi
    if [[ -n "${usage_msg}" ]]; then # Print usage message if one is given
        echo >&2
        echo "${usage_msg}" >&2
    fi
    if [[ "${ret}" =~ ^[0-9]+$ ]]; then # Exit with custom exit code if given
        exit "${ret}"
    else
        exit 1
    fi
fi

# If we got here then the number of arguments is within bounds, exit 0
exit 0

# # First check if any argument before the delimiter is -h or --help
# if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
#     echo "${USAGE}" # If so print usage
#     exit 0
# fi

# # Function to check the number of arguments
# LO_BOUND=$1
# HI_BOUND=$2
# EX_CODE=$3
# USE_MSG=$4
# ERR_MSG=$5

# # Find the control argument '--' delimiter
# for (( i=1; i<=$#; i++ )); do
#     if [[ "${!i}" == "--" ]]; then
#         DELIM_IDX=$i
#         break
#     fi
# done

# # Error if no delimiter found
# if [[ -z "${DELIM_IDX}" ]]; then
#     echo
#     echo "No '--' delimiter found in util/arch/check-num.sh!" >&2
#     echo
#     echo "$USAGE" >&2
#     exit 2
# fi

# # Calculate the number of arguments after the delimiter
# ARG_COUNT=$(( $# - DELIM_IDX - 1))

# # Check if the number of arguments is within specified bounds
# # NOTE: if the bounds are equal, you're checking for a specific number of args
# if [[ "${ARG_COUNT}" -lt "${LO_BOUND}" ]] || [[ -n "${HI_BOUND}" && "${ARG_COUNT}" -gt "${HI_BOUND}" ]]; then
#     if [[ -n "${ERR_MSG}" ]]; then
#         echo >&2
#         echo "${ERR_MSG}" >&2
#     fi
#     if [[ -n "${USE_MSG}" ]]; then
#         echo >&2
#         echo "${USE_MSG}" >&2
#     fi
#     if [[ -n "${EX_CODE}" ]]; then
#         exit "${EX_CODE}"
#     else
#         exit 1
#     fi
# fi

# # If it fails to exit from the above, then the arguments pass the check
# exit 0
