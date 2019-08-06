#!/usr/bin/env bash

function main() {
    readonly local project=$(dirname $(dirname $(dirname $(dirname $(dirname $(readlink -f "$0"))))))
    readonly local pre_commit_dst="$project/.git/hooks/pre-commit"
    readonly local pre_push_dst="$project/.git/hooks/pre-push"

	[[ -f "$pre_commit_dst" ]] && rm "$pre_commit_dst"
	[[ -f "$pre_push_dst" ]] && rm "$pre_push_dst"

    ln -s "pre-commit.sh" "$pre_commit_dst"
    ln -s "pre-push.sh" "$pre_push_dst"

    if [[ -z "$(grep check.php "$project/.git/config")" ]]; then
        printf "[check.php]\n\tsyntax = true\n\tdumps = true\n\tconflicts = true\n" >> .git/config
    fi
}

main
