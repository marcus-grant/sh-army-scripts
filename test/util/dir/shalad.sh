#!/usr/bin/env bats
ACTUAL_PROJECT_DIR="$HOME/Archive/shallad/util/dir"

@test "returns the correct root path" {
    cd ../../util/dir/shalad.sh
    result="$(./shalad-dir.sh)"
    [ "$result" == "$ACTUAL_PROJECT_DIR" ]
}
