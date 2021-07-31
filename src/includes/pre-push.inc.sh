#!/usr/bin/env bash

# This include-file contains functions used in pre-push.sh.

function usage_help() {
	echo -e "$(bold)Usage:$(clr)
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

function print_version() {
	echo -e "pre-push.sh $(bold)${VERSION}$(clr) by Yancharuk Alexander\n"

	return 0
}

# Function returns list of changed PHP files
function get_commit_files() {
	git diff-tree --no-commit-id --name-only -r "$1" | grep -E '(.php|.phtml)$'

	return $?
}

function check_style() {
	local result=0
	local local_ref
	local local_sha
	local remote_ref
	local remote_sha
	local file
	local files
	local range

	while read -r local_ref local_sha remote_ref remote_sha; do
		if [[ ${local_sha} != "$Z40" ]]; then
			if [[ ${remote_sha} = "$Z40" ]]; then
				# New branch, examine all commits
				range="$local_sha"
			else
				# Update to existing branch, examine new commits
				range="$remote_sha..$local_sha"
			fi

			while read -r file; do
				if [[ -e "$PROJECT_PATH/$file" ]]; then
					files="$files\n$file"
				fi
			done < <(get_commit_files "$range")
		fi
	done

	files=$(echo -en "$files" | grep . | sort -u | tr '\n' ' ')

	if [[ -z "$files" ]]; then
		inform 'No files for style check'
	else
		cd "$PROJECT_PATH" || exit 1

		while read -r file; do
			git cat-file -p "HEAD:$file" | vendor/bin/phpcs --colors -sn --stdin-path="$file" -
		done <<< "$files"

		result=$?

		status 'Code Sniffer style check' ${result}
	fi

	return ${result}
}

function run_phpunit() {
	cd "$PROJECT_PATH" || exit 1

	vendor/bin/phpunit

	result=$?

	return ${result}
}

function main() {
	local -r style_flag=$(git_config_bool check.php.style "$PROJECT_PATH")
	local -r phpunit_flag=$(git_config_bool check.php.phpunit "$PROJECT_PATH")

	[[ ${style_flag} == 1 ]] || [[ ${phpunit_flag} == 1 ]] || exit 0

	check_dependencies git php grep sort tr || exit 1

	if [[ ${style_flag} == 1 ]]; then
		check_style "$@" || exit 1
	fi

	if [[ ${phpunit_flag} == 1 ]]; then
		run_phpunit || exit 1
	fi
}
