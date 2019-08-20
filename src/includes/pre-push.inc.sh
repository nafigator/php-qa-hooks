#!/usr/bin/env bash

usage_help() {
	printf "$(bold)Usage:$(clr)
  pre-push.sh [OPTIONS...]

$(bold)Options:$(clr)
  -v, --version              Show script version
  -h, --help                 Show this help message
  -d, --debug                Run program in debug mode

$(bold)Description:$(clr)
  Git-hooks intend for PHP code style checks in commits before push.

$(bold)Configuration:$(clr)
  In file $(bold).git/config$(clr) in [check.php] section you can enable
  or disable check by parameter. Same via git commands:

  git config check.php.style [false|true]

$(bold)WWW:$(clr)
  https://www.php-fig.org/psr/psr-2
  https://www.php-fig.org/psr/psr-12

"

	return 0
}

print_version() {
	printf "pre-push.sh $(bold)${VERSION}$(clr) by Yancharuk Alexander\n\n"

	return 0
}

# Function returns list of changed PHP files
get_commit_files() {
	git diff-tree --no-commit-id --name-only -r $1 | egrep '(.php|.phtml)$'

	return $?
}

check_style() {
	local result=0
	local local_ref
	local local_sha
	local remote_ref
	local remote_sha
	local file
	local files
	local range

	while read local_ref local_sha remote_ref remote_sha; do
		if [[ ${local_sha} != ${Z40} ]]; then
			if [[ ${remote_sha} = ${Z40} ]]; then
				# New branch, examine all commits
				range="$local_sha"
			else
				# Update to existing branch, examine new commits
				range="$remote_sha..$local_sha"
			fi

			while read file; do
				if [[ -e "$PROJECT_PATH/$file" ]]; then
					files="$files\n$file"
				fi
			done < <(get_commit_files ${range})
		fi
	done

	files=$(printf "$files" | grep . | sort -u | tr '\n' ' ')

	if [[ -z "$files" ]]; then
		inform 'No files for style check'
	else
		cd ${PROJECT_PATH}
		vendor/bin/phpcs -n ${files}

		result=$?

		status 'Code Sniffer style check' ${result}
	fi

	return ${result}
}

run_phpunit() {
	cd ${PROJECT_PATH}

	vendor/bin/phpunit

	result=$?

	return ${result}
}

main() {
	readonly local style_flag=$(git_config_bool check.php.style ${PROJECT_PATH})
	readonly local phpunit_flag=$(git_config_bool check.php.phpunit ${PROJECT_PATH})

	[[ ${style_flag} == true ]] || [[ ${phpunit_flag} == true ]] || exit 0

	check_dependencies git php grep sort tr || exit 1

	if [[ ${style_flag} == true ]]; then
		check_style ${@} || exit 1
	fi

	if [[ ${phpunit_flag} == true ]]; then
		run_phpunit || exit 1
	fi
}
