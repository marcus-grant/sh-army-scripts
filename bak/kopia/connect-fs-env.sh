#!/bin/bash
USAGE=$(cat << 'EOF'
USAGE:
    $0 [-h|--help] env_file [args...]

DESCRIPTION:
    Connects to a kopia repository with the given environment variables.
    Simply loads KOPIA_PASSWORD & KOPIA_PATH from the given env_file,
    and uses the "kopia repository connect filesystem" command with
    the parameters in those environment variables.

ARGUMENTS:
    -h, --help  (OPTIONAL) Show this help message.
    env_file    The file containing the environment variables to load.
    args...     (OPTIONAL) Any arguments/subcommadns to pass to
                    the kopia command along with wrapped environment variables.
                    DELETEME?

VARIABLES:
    KOPIA_PASSWORD  The password to use when connecting to the kopia repository.
    KOPIA_PATH      The path to the kopia repository.

RETURNCODES:
    0   The command ran successfully.
    1   The variable file given cant load, or non-existant.
    2   The command given cant be run.

EXAMPLE:
    First before a real example show contents of a kopia.env file:
        cat ~/.restic/repos/kopia.env
        /# Output:
        KOPIA_PASSWORD="password"
        KOPIA_PATH="~/Archive/kopia"
    
    Now its possible to quickly run kopia commands with the above credentials:
        $0 ~/.restic/repos/kopia.env snapshot list


EOF
)

# Check for -h or --help in arguments, print usage if so and exit successfully
util/arg/check-help.sh -e 2 -u "$USAGE" -- "${@}" || exit 0

# DELETEME: Don't think we'll be making this one wrap the whole command chain
# Check for at least 2 arguments, if not print error and usage
# ERR_MSG="ERROR in $0: Command to wrap and/or environment file is missing!"
# util/arg/check-num.sh -m 2 -u "$USAGE" -e "$ERR_MSG" -- "${@}" || exit 2

# Pull out the environment file
env_file="${1}"
# echo "env_file: ${env_file}" # DEBUG
shift

# Pull out the kopia subcommand and arguments
kopia_argv=("${@}")
# echo "kopia_argv: ${kopia_argv[*]}" # DEBUG
# echo "kopia_argv length: ${#kopia_argv[@]}" # DEBUG

# Use util/env/wrap.sh to wrap the kopia command with the given env file
set -a
# shellcheck disable=SC1090
source "$env_file"
# echo "KOPIA_PATH: ${KOPIA_PATH}" # DEBUG
# echo "KOPIA_PASSWORD: ${KOPIA_PASSWORD}" # DEBUG
if [ ${#kopia_argv[@]} -eq 0 ]; then
    # echo "Args are empty" # DEBUG
    kopia repository connect filesystem \
        --path "$KOPIA_PATH" --password "$KOPIA_PASSWORD"
else
    kopia repository connect filesystem \
        --path "$KOPIA_PATH" --password "$KOPIA_PASSWORD" "${kopia_argv[@]}"
fi
set +a