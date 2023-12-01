#!/bin/bash
CMD_NAME="$0"
USAGE=$(cat << EOF
USAGE:
    $CMD_NAME [-h|--help] [-d|--debug] env_file subcommands [args...]

DESCRIPTION:
    Wraps the kopia subcommands and arguments with
    a given set of environment variables loaded from an *.env file.
    It also executes the command with the connect and disconnect subcommands
    before and after the given kopia subcommand respectively.
    This simplifies the process of connecting to a repository,
    and performing repository operations.

ARGUMENTS:
    -h, --help  (OPTIONAL) Show this help message.
    -d, --debug (OPTIONAL) Print debug messages. MUST BE FIRST ARGUMENT!
    env_file    The file containing the environment variables to load.
    subcommands The kopia subcommands to run wrapped with
                    loaded environment variables.
    args...     (OPTIONAL) Any arguments to pass to the kopia command along
                    with wrapped environment variables.

ENVIRONMENT VARIABLES:
    KOPIA_PASSWORD  The password to use when connecting to the kopia repository.
    KOPIA_PATH      The path to the kopia repository.

EXAMPLE:
    First before a real example show contents of a kopia.env file:
        cat ~/.restic/repos/kopia.env
        /# Output:
        KOPIA_PASSWORD="password"
        KOPIA_PATH="~/Archive/kopia"
    
    Now its possible to quickly run kopia commands with the above credentials:
        $CMD_NAME ~/.restic/repos/kopia.env snapshot list

EOF
)
# Check for -h or --help in arguments, print usage if so and exit successfully
util/arg/check-help.sh -u "$USAGE" -- "${@}" && exit 0
# Check for -d or --debug in arguments, print debug messages if so
DEBUG=false; util/arg/check-flag.sh -d,--debug 1 -- "${@}" && DEBUG=true
$DEBUG && shift # shift out the debug flag if it was given

# Check if kopia is already connected, if so print error and exit
kopia repository status > /dev/null 2>&1 && {
    $DEBUG && echo "Currently connected to a kopia repository!"
    kopia repository disconnect > /dev/null 2>&1
}

# Pull out the environment file
env_file="${1}"
shift
$DEBUG && echo "env_file: ${env_file}"

# Use bak/kopia/connect-env.sh to wrap kopia commands with the given env file
# & ensure a connection is made to a repo & disconnected when command is done.
bak/kopia/connect-fs-env.sh "${env_file}"

# Now run the given kopia subcommand with the given arguments
kopia "${@}"

# Disconnect from the kopia repository
kopia repository disconnect 
