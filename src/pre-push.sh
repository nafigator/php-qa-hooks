#!/usr/bin/env bash

PROJECT_PATH=$(dirname $(dirname $(dirname $(dirname $(dirname $(readlink -f "$0"))))))
VERSION=0.5.3
z40=0000000000000000000000000000000000000000

cd ${PROJECT_PATH}/vendor/nafigator
. bash-helpers/src/bash-helpers.sh
. php-qa-hooks/src/includes/pre-push.inc.sh

parse_options ${@}
PARSE_RESULT=$?

[[ ${PARSE_RESULT} = 1 ]] && exit 1
[[ ${PARSE_RESULT} = 2 ]] && usage_help && exit 2

check_dependencies git php || exit 1

while read local_ref local_sha remote_ref remote_sha; do
	if [[ ${local_sha} != ${z40} ]]; then
		if [[ ${remote_sha} = ${z40} ]]; then
			# New branch, examine all commits
			range="$local_sha"
		else
			# Update to existing branch, examine new commits
			range="$remote_sha..$local_sha"
		fi

		while read file; do
			if [[ -e "$PROJECT_PATH/$file" ]]; then
				files="$files $file"
			fi
		done < <(get_commit_files ${range})
	fi
done

if [[ -z "$files" ]]; then
	inform 'No files for style check'
	exit 0
fi

cd ${PROJECT_PATH}
vendor/bin/phpcs -n ${files}

result=$?

status 'Code Sniffer style check' ${result}

exit ${result}
