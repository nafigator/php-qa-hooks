#!/usr/bin/env bash

# Install and configure pre-commit and pre-push hooks.

function main() {
    local -r project=$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")")")
    local -r src=$(dirname "$(readlink -f "$0")")
    local -r config="$project/.git/config"
    local -r hooks_dir="$project/.git/hooks"
    local -r pre_commit_dst="$hooks_dir/pre-commit"
    local -r pre_push_dst="$hooks_dir/pre-push"

    [[ -f "$pre_commit_dst" ]] && rm "$pre_commit_dst"
    [[ -f "$pre_push_dst" ]] && rm "$pre_push_dst"

    cp -u "$src/pre-commit.sh" "$pre_commit_dst"
    cp -u "$src/pre-push.sh" "$pre_push_dst"

    if ! grep -q check.php "$config"; then
        printf "[check.php]\n\tcolors = true\n\tconflicts = true\n\tdumps = true\n\tphpunit = false\n\tstyle = true\n\tsyntax = true\n" >> "$config"
    fi
}

main
