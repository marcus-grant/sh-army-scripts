#!/bin/bash
USAGE=$(cat << 'EOF'
USAGE:
    check-help.sh [-h|--help] [-D|--debug] [-u|--usage msg] \\
                    [-s|--start start] [-e|--end end] \\
                    [-o short_opt] [-O long_opt] -- [arguments...]

DESCRIPTION:
    Checks for -h or --help in the given arguments.
    The goal of this script is to reduce the amount of usage message boilerplate.
    The only necessary arguments are the usage message and the delimiter between
    control arguments and positional arguments.

ARGUMENTS:
    -h, --help          Print THIS scripts usage message.
    -D, --debug         Prints debug lines to debug this script.
    -u, --usage msg     Custom usage message to display when help flag is found.
    -s, --start start   The starting index of the range to check (default 1).
    -e, --end   end       The ending index of the range to check (default $#).
    -o, --short option  Specify a custom short help flag other than
                            "-h" to search for after the "--" delimiter.
    -O, --long  option  Specify a custom short help flag other than
                            "-h" to search for after the "--" delimiter.
    -- (REQUIRED)       Delimiter indicating the end of control arguments.
                            Args to check for help flags start after here.
    arguments           The arguments to check for help flags,
                            like a calling scripts \$@.

RETURNCODES:
    (SIGNALS)
    0       Help flag NOT found (continue execution in calling script).
    1       Help flag found.
    2       Help flag found for this script (i.e., not for the passed args).
    (ERRORS)
    3       No -- delimiter found in this script!
    4       Invalid control argument given for this script.

Examples:
    Check all arguments for help flags (all default control options for script):
        util/arg/check-help.sh -- "$@"
    
    Check 2nd, 3rd & 4th args for help flags with custom usage message if found:
        util/arg/check-help.sh -u "Custom usage message!" -s 2 -e 4 -- "$@"
    
    Check all all passed args for help flags with custom message,
        and non-default help flags --usage and -u:
        util/arg/check-help.sh -u "Custom usage message!" -o u -O usage -- "$@"

EOF
)

# Check for -h or --help before the delimiter
for (( i=1; i<=$#; i++ )); do
    arg=${!i}
    if [[ "${arg}" == "-h" ]] || [[ "${arg}" == "--help" ]]; then
        echo
        echo "$USAGE"
        exit 2
    fi
    if [[ "${arg}" == "--" ]]; then
        break
    fi
done

# If no help if found before delimiter (--),
# delimiter must exist in this scripts args
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
    echo "No '--' delimiter found in check-help.sh script!" >&2
    echo
    echo "$USAGE" >&2
    exit 3
fi


# Default values for control arguments
usage_msg=""
start=1
end=$#
short_flag="-h"
long_flag="--help"
debug="false"

# Check for control arguments and override defaults if found
# First check for a non-default usage message and stop if 
# Iterate through the arguments
while [[ $# -gt 0 ]]; do
    delim_idx=$(( delim_idx + 1 ))
    case $1 in
        -D|--debug)
            debug="true"
            ;;
        -u|--usage)
            shift
            usage_msg=$1
            ;;
        -s|--start)
            shift
            start=$1
            ;;
        -e|--end)
            shift
            end=$1
            ;;
        -o)
            shift
            short_flag=$1
            ;;
        -O)
            shift
            long_flag=$1
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid argument: $1"
            echo "$USAGE"
            exit 1
            ;;
    esac
    shift
done

# DEBUG: All overridden values
if [[ "$debug" == "true" ]] ; then
    echo "usage_msg: $usage_msg"
    echo "start: $start"
    echo "end: $end"
    echo "short_flag: $short_flag"
    echo "long_flag: $long_flag"
    echo "\$@: ${*}"
    echo "\$#: $#"
fi

# Now we can finally check for the help flag in either long_flag or short_flag
# ... in the rest of the arguments past the delimiter
shift # first to ignore the command name as an argument
for (( i=start; i<=end; i++ )); do
    arg=${!i}
    # Exit early if i is greater than the number of arguments
    if [[ "$i" -gt "$#" ]]; then
        break
    fi
    # If debug print arg and index
    if [[ "$debug" == "true" ]] ; then
        echo "arg: $arg"
        echo "i: $i"
    fi
    if [[ "${arg}" == "-${short_flag}" ]] || [[ "${arg}" == "--${long_flag}" ]];
    then
        # If usage message is non-empty, print it
        if [[ -n "${usage_msg}" ]]; then
            echo
            echo "$usage_msg"
        fi
        # If debug is true, print debug info
        if [[ "$debug" == "true" ]] ; then
            echo "Found help flag, exiting with code 1."
        fi
        exit 1
    fi
done

# Done, no help flag found
if [[ "$debug" == "true" ]] ; then
    echo "No help flag found, exiting with code 0."
fi
exit 0
