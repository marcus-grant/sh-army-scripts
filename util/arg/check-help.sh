#!/bin/bash
USAGE=$(cat << 'EOF'
Description:
  Checks for '-h' or '--help' in the given arguments.
  Optionally checks within a specified range.

Usage:
    check-help.sh [start] [end] -- [arguments...]

Arguments:
    start      (optional) The starting index of the range to check (inclusive).
    end        (optional) The ending index of the range to check (inclusive).
    --         Delimiter indicating the end of options and the beginning of positional arguments.
    arguments  The arguments to check for help flags.

Return Codes:
    0   Help flag found.
    1   Help flag not found.
   16   Invalid arguments given.
  255   Help flag found for this script.

Examples:
  Check all arguments for help flags:
    ./check-help.sh -- "$@"

  Check only arguments 2 to 4 for help flags:
    ./check-help.sh 2 4 -- "$@"

SHalad Module: util/arg
EOF
)

# First check if this script is having help requested
if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
    echo "${USAGE}" # If so print usage
    exit 255 # Since help was requested for this script, not someone else's fail
fi

# Parse optional start & end args, separating them from cmd args if exist
if [[ $1 =~ ^[0-9]+$ ]] && [[ $2 =~ ^[0-9]+$ ]] && [[ $3 == "--" ]]; then
    arg_start=$1
    arg_end=$2
    shift 3  # Shift past start, end, and --
elif [[ $1 =~ ^[0-9]+$ ]] && [[ $2 == "--" ]]; then
    arg_start=$1
    arg_end=$#
    shift 2  # Shift past start and --
elif [[ $1 == "--" ]]; then
    arg_start=1
    arg_end=$#
    shift  # Shift past --
else
    echo "$USAGE"
    exit 16
fi

for (( i=arg_start; i<=arg_end; i++ )); do
    arg=${!i} # Get argument at index
    # DEBUG
    # echo "Checking argument ${i}: ${arg}"
    if [[ "${arg}" == "-h" ]] || [[ "${arg}" == "--help" ]]; then
        # DEBUG
        # echo "Help flag found!"
        exit 0
    fi
done

exit 1
