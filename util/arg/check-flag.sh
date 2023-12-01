#!/bin/bash
CMD_NAME="$0"
USAGE=$(cat << EOF
USAGE:
    ${CMD_NAME} [-h|--help] FLAG [END] [START] -- ARGS...

DESCRIPTION:
    Checks for the presence of a flag option in the given arguments.
    The flag can be specified as a short or long option and can be checked
    either within a range of arguments or all of them. The arguments being
    checked for must appear after the -- delimiter.

ARGUMENTS:
    -h, --help          Show this help message.
    FLAG                The flag option to check for.
                            Can be many flags by separating with comma (f1,f2).
    END                 The last argument past -- to check (default $#).
                            The END comes 1st since ignoring flags tends to
                            happen near the end of the arguments.
    START               The starting index of the range to check (default 1).
    --                  (REQUIRED) Delimiter separating control arguments from
                        another set of arguments to check the number of.
    ARGS...             The arguments to check for the flag option.
RETURNCODES:
    (SIGNALS)
    0       Flag option found.
    1       Flag option NOT found.
    (ERRORS)
    2       Help flag found for this script (i.e., not for the passed args).
    3       No -- delimiter found in this script!
    4       Invalid control argument given for this script.

EXAMPLES:
    Check all arguments for -d, --debug flag (all default control options elsewhere),
        and exit with code 0 if found:
            $CMD_NAME -h,--help -- "$@" || exit 0
    
    Check for -d flag up to 2nd argument (1st and 2nd args) and set DEBUG flag.
            DEBUG=false ; $CMD_NAME -d 2 -- "$@" && DEBUG=true
    
    Check 2nd, 3rd & 4th args for -d and --debug flags.:
        $CMD_NAME -d,--debug 2 4 -- "$@"
    
EOF
)
# First check for the delimiter and help flag before it
DELIM_EXISTS=false
HELP_EXISTS=false
for (( i=1; i<=$#; i++ )); do
    arg=${!i}
    # Check if the help flag is found before the delimiter
    if [[ "${arg}" == "-h" ]] || [[ "${arg}" == "--help" ]]; then
        HELP_EXISTS=true
    fi
    if [[ "${arg}" == "--" ]]; then
        DELIM_EXISTS=true
        break
    fi
done
# If neither the help flag or delimiter are found, print error, usage and exit
if ! $HELP_EXISTS && ! $DELIM_EXISTS; then
    echo
    echo "ERROR in $0: No -- delimiter found!" >&2
    echo
    echo "$USAGE" >&2
    exit 3
fi
# If the help flag exists without the delimiter, print usage and exit
if $HELP_EXISTS && ! $DELIM_EXISTS; then
    echo
    echo "$USAGE"
    exit 2
fi

# If you're here, there's no help flag before the delimiter and
# the delimiter exists, so start shifting out variables till the delimiter.

# First, pull out the FLAG text to search for from the first argument
FLAG="${1}"

# If the FLAG is the delimiter, print error, usage and exit
if [[ "${FLAG}" == "--" ]]; then
    echo "ERROR in $0: No flag text provided before '--' delimiter." >&2
    echo -e "\tFirst argument needed to search for flag past '--' delimiter." >&2
    echo
    echo "$USAGE" >&2
    exit 4
fi

# Set default values for END and START
END=0 # Set to zero to later set to $# after shifting out args to --
START=1

# Shift out the FLAG argument, already captured
shift

# Check for the END argument before the delimiter
if [[ "${1}" != "--" ]]; then
    END="${1}" # If not the delimiter, we have an END argument
    shift # END is captured, so shift arguments
    # Check for the START argument before the delimiter
    if [[ "${1}" != "--" ]]; then
        START="${1}" # If not the delimiter, we have a START argument
        shift # START is captured, so shift arguments
    fi
fi

# Check that no more arguments exist before the delimiter
if [[ "${1}" != "--" ]]; then
    echo "ERROR in $0: Too many arguments provided before '--' delimiter!" >&2
    echo
    echo "$USAGE" >&2
    exit 4
fi
shift # Shift out the delimiter, we have all control arguments needed

# Validate the END and START values as numbers
if ! [[ "${END}" =~ ^[0-9]+$ ]]; then
    echo "ERROR in $0: Invalid END argument provided!" >&2
    echo
    echo "$USAGE" >&2
    exit 4
fi
if ! [[ "${START}" =~ ^[0-9]+$ ]]; then
    echo "ERROR in $0: Invalid START argument provided!" >&2
    echo
    echo "$USAGE" >&2
    exit 4
fi

# Adjust the END argument to be either $# (default = 0) or the given END
END=$(( END == 0 ? $# : END ))
# Adjust the FLAG argument to be an array of flags split by comma
IFS=',' read -r -a FLAGS <<< "${FLAG}"

# With all control arguments and the delimiter captured, validated and shifted,
# it's finally time to check for the FLAG flag within the remaining arguments.
# Loop through the remaining arguments
for (( i=START; i<=END; i++ )); do
    arg=${!i} # Pull out argument
    # Check if the argument matches any of the flags
    for flag in "${FLAGS[@]}"; do
        if [[ "${arg}" == "${flag}" ]]; then
            # If the argument matches a flag, return 0 and exit
            exit 0
        fi
    done
done

# If you're here, the FLAG was not found, so return 1 and exit
exit 1
