#!/usr/bin/env bash

function main() {
    readonly local project=$(dirname $(dirname $(dirname $(dirname $(dirname $(readlink -f "$0"))))))
    readonly local config="$project/.git/config"
    readonly local hooks_dir="$project/.git/hooks"
    readonly local pre_commit_dst="$hooks_dir/pre-commit"
    readonly local pre_push_dst="$hooks_dir/pre-push"

    [[ -f "$pre_commit_dst" ]] && rm "$pre_commit_dst"
    [[ -f "$pre_push_dst" ]] && rm "$pre_push_dst"

    if [[ ! -z "$(grep check.php ${config})" ]]; then
        git config --remove-section check.php
    fi
}

main
