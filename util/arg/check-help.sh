#!/bin/bash
USAGE=$(cat << 'EOF'
USAGE:
    check-help.sh [-h|--help] [-D|--debug] [-u|--usage MSG] \\
                    [-s|--start START] [-e|--end END] \\
                    [-f|--short SHORT] [-F|--long LONG] -- [ARGS...]

DESCRIPTION:
    Checks for -h or --help in the given arguments.
    The goal of this script is to reduce the amount of usage message boilerplate.
    The only necessary arguments are the -- delimiter which marks the end of
    control arguments and data arguments to search for help flags in.
    This uses util/arg/check-flag.sh to check for the help flag.
    But adds functionality by allowing the user to specify a -u|--usage message
    to print if the help flag is found.

ARGUMENTS:
    -h, --help          Print THIS scripts usage message.
    -D, --debug         Prints debug lines to debug this script.
    -u, --usage msg     Custom usage message to display when help flag is found.
    -s, --start start   The starting index of the range to check (default 1).
    -e, --end   end       The ending index of the range to check (default $#).
    -f, --short SHORT  Specify a custom short help flag to find after the "--"
                            (default -h).
    -O, --long  option  Specify a custom long help flag to find after the "--"
                            (default --help)
    -- (REQUIRED)       Delimiter indicating the end of control arguments.
                            Args to check for help flags start after here.
    ARGS...           The arguments to check for help flags in.

RETURNCODES:
    (SIGNALS)
    0       Help flag found.
    1       Help flag NOT found (continue execution in calling script).
    2       Help flag found in control args (i.e., print usage for this script).
    (ERRORS)
    3       No -- delimiter found in this script!
    4       Invalid control argument given for this script.

Examples:
    Check all arguments for help flags (all default control options for script),
        and exit with code 0 if found:
            check-help.sh -- "$@" && exit 0
    
    Check 2nd, 3rd & 4th args for help flags with custom usage message if found:
        check-help.sh -u "Custom usage message!" -s 2 -e 4 -- "$@" && exit 0
    
    Check all all passed args for help flags with custom message,
    and non-default help flags --usage and -u:
        check-help.sh -u "Custom usage message!" -f -u -F --usage -- "$@"

EOF
)

# Check for -h or --help before the delimiter (assuming within 2 args)
util/arg/check-flag.sh -h,--help 2 -- "${@}" && { echo "$USAGE"; exit 2; }

# If you're here, then we can stop worrying about help flags as control args.
# So we can start checking all other control arguments before the -- delimiter.
# Start by setting default values for control arguments
USAGE_MSG=""
START=1
END=0 # 0 is a marker for no end specified, we'll change this to $# later
SHORT_FLAG="-h"
LONG_FLAG="--help"
DEBUG="false"

# Check for control arguments and override defaults if found
# First check for a non-default usage message and stop if 
# Iterate through the arguments
while [[ $# -gt 0 ]]; do
    arg="${1}"
    shift
    if [[ $DEBUG == "true" ]]; then
        echo "(while)arg: $arg"
        echo "(while)\$#: $#"
        echo "(while)\$@: ${*}"
    fi
    case $arg in
        -D|--debug)
            if [[ "$DEBUG" == "true" ]]; then echo "(case -D)arg: true"; fi
            DEBUG="true"
            ;;
        -u|--usage)
            if [[ "$DEBUG" == "true" ]]; then echo "(case -u)arg: $1"; fi
            USAGE_MSG="${1}"
            shift
            ;;
        -s|--start)
            if [[ "$DEBUG" == "true" ]]; then echo "(case -s)arg: $1"; fi
            START="${1}"
            shift
            ;;
        -e|--end)
            if [[ "$DEBUG" == "true" ]]; then echo "(case -e)arg: $1"; fi
            END="${1}"
            shift
            ;;
        -f|--short)
            if [[ "$DEBUG" == "true" ]]; then echo "(case -f)arg: $1"; fi
            SHORT_FLAG="${1}"
            shift
            ;;
        -F|--long)
            if [[ "$DEBUG" == "true" ]]; then echo "(case -F)arg: $1"; fi
            LONG_FLAG="${1}"
            shift
            ;;
        --)
            if [[ "$DEBUG" == "true" ]]; then echo "(case --): delim found!"; fi
            shift
            break
            ;;
        *)
            echo "Invalid argument: $1"
            echo "$USAGE"
            exit 1
            ;;
    esac
done

# Validate the control arguments
if ! [[ "$END" =~ ^[0-9]+$ ]] ; then # Validate END is a number
    echo "ERROR in $0: END argument ($END), is not a number!" >&2
    echo "$USAGE" >&2
    exit 4
fi
if ! [[ "$START" =~ ^[0-9]+$ ]] ; then # Validate START is a number
    echo "ERROR in $0: START argument ($START), is not a number!" >&2
    echo "$USAGE" >&2
    exit 4
fi
if [[ "$END" -eq 0 ]]; then # END=0 wasn't overriden, set to $# after shifts
    END="$#"
fi
if [[ "$END" -lt "$START" ]] ; then # Validate END >= START
    echo "ERROR in $0: END arg ($END), is less than START arg ($START)!" >&2
    echo "$USAGE" >&2
    exit 4
fi

# DEBUG: All overridden values
if [[ "$DEBUG" == "true" ]] ; then
    echo "DEBUG: All control arg values:"
    echo "USAGE_MSG: $USAGE_MSG"
    echo "START: $START"
    echo "END: $END"
    echo "SHORT_FLAG: $SHORT_FLAG"
    echo "LONG_FLAG: $LONG_FLAG"
    echo "\$@: ${*}"
    echo "\$#: $#"
fi


# Use util/arg/check-flag.sh to check for the help flag using the control args
util/arg/check-flag.sh "${SHORT_FLAG},${LONG_FLAG}" "$END" "$START" -- "${@}"
RESULT=$?
$DEBUG && echo "RESULT: $RESULT" # DEBUG

# This check script is meant to cut down on boilerplate usage message code.
# So if no help flag found $? == 1, continue executing in calling script.
# For example check-help.sh -u "USAGE MESSAGE" -- "$@" && exit 0
if [[ $RESULT -ne "0" ]]; then exit 1; fi # Flag not found, exit with code 1 

# If help flag not found check if a USAGE message was given, if so print it
if [[ -n "$USAGE_MSG" ]]; then
    echo
    echo "$USAGE_MSG"
fi

# Then finally exit with code 0
exit 0
