#!/usr/bin/env bash

function main() {
    readonly local project=$(dirname $(dirname $(dirname $(dirname $(dirname $(readlink -f "$0"))))))
    readonly local src=$(dirname $(readlink -f "$0"))
    readonly local config="$project/.git/config"
    readonly local hooks_dir="$project/.git/hooks"
    readonly local pre_commit_dst="$hooks_dir/pre-commit"
    readonly local pre_push_dst="$hooks_dir/pre-push"

    [[ -f "$pre_commit_dst" ]] && rm "$pre_commit_dst"
    [[ -f "$pre_push_dst" ]] && rm "$pre_push_dst"

    cp -u "$src/pre-commit.sh" "$pre_commit_dst"
    cp -u "$src/pre-push.sh" "$pre_push_dst"

    if [[ -z "$(grep check.php ${config})" ]]; then
        printf "[check.php]\n\tsyntax = true\n\tdumps = true\n\tconflicts = true\n\tstyle = true\ncolors = true\n" >> ${config}
    fi
}

main
