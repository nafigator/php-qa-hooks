#!/usr/bin/env bash

# Uninstall and configure cleanup for pre-commit and pre-push hooks.

function main() {
    local -r project=$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")")")
    local -r config="$project/.git/config"
    local -r hooks_dir="$project/.git/hooks"
    local -r pre_commit_dst="$hooks_dir/pre-commit"
    local -r pre_push_dst="$hooks_dir/pre-push"

    [[ -f "$pre_commit_dst" ]] && rm "$pre_commit_dst"
    [[ -f "$pre_push_dst" ]] && rm "$pre_push_dst"

    if grep -q check.php "$config"; then
        git config --remove-section check.php
    fi
}

main
