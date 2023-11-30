#!/bin/bash
USAGE=$(cat << 'EOF'
USAGE:
    _/util/env/wrap.sh [-h|--help] env_file command [args...]

DESCRIPTION:
    Wraps a command to be executed with a given set of
    environment variables loaded from a file.

ARGUMENTS:
    -h, --help  (OPTIONAL) Show this help message.
    env_file    The file containing the environment variables to load.
    command     The command to run wrapped with loaded environment variables.
    args...     (OPTIONAL) Any arguments to pass to the wrapped command.

RETURNCODES:
    0   The command ran successfully.
    1   The variable file given can't load, or non-existant.
    2   The command given can't be run.

EXAMPLE:
    Run the command "restic snapshots" with B2 credentials loaded:
        wrap.sh ~/.restic/repos/b2-repo.env restic snapshots
    
    Example where we create an env file and use wrap to echo a variable:
        echo "export FOO=BAR\\n" > /tmp/foobar.env
        util/env/wrap.sh echo "FOO$FOO" # Output: FOOBAR

EOF
)

# Check for -h or --help in arguments, print usage if so and exit successfully
util/arg/check-help.sh -u "$USAGE" -- "${@}" || exit 0

# Check for debug flag in first arg
DEBUG=false
if [[ "${1}" == "-d" ]] || [[ "${1}" == "--debug" ]]; then
    DEBUG=true
    shift
    echo
    echo "DEBUG Mode in $0!"
fi

# Check for at least 2 arguments, if not print error and usage
ERR_MSG="ERROR in $0: Command to wrap and/or environment file is missing!"
util/arg/check-num.sh -m 2 -u "$USAGE" -e "$ERR_MSG" -- "${@}" || exit 2

# Check if variable file exists
var_file="${1}"
shift
$DEBUG && echo; echo "var_file: ${var_file}" # Debug mode for var_file
ERR_MSG="\nERROR in $0: Variable file (${var_file}) not found!\n\n$USAGE"
[ -f "${var_file}" ] || { echo -e "$ERR_MSG" >&2; exit 1; }

# Check if command is valid
# DELETEME this is not needed, the command will fail if it's invalid
# ERR_MSG="\nERROR in $0: Command to wrap (${1}) wont run!\n\n$USAGE"
# command -v "${1}" &> /dev/null || { echo -e "$ERR_MSG" >&2; exit 2; }

# Source the environment file
set -a  # Automatically export all variables
# shellcheck disable=SC1090
source "$var_file"
$DEBUG && echo; echo "var_file: ${var_file}" # Debug mode for var_file
set +a  # Stop automatically exporting variables

# Execute the command with the remaining arguments
$DEBUG && echo; echo "command: ${*}"
"$@"
exit $?
