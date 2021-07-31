#!/usr/bin/env bash

# This include-file contains functions used in pre-commit.sh.

usage_help() {
	echo -e "$(bold)Usage:$(clr)
  pre-commit.sh [OPTIONS...]

$(bold)Options:$(clr)
  -v, --version              Show script version
  -h, --help                 Show this help message
  -d, --debug                Run program in debug mode

$(bold)Description:$(clr)
  Git-hooks intend for PHP-syntax commit checks, check for git-conflicts and
  forgotten var dumps.

$(bold)Configuration:$(clr)
  In file $(bold).git/config$(clr) in [check.php] section you can enable
  or disable check by parameters. Same via git commands:

  git config check.php.syntax [false|true]
  git config check.php.conflicts [false|true]
  git config check.php.dumps [false|true]
"

	return 0
}

print_version() {
	echo -e "pre-commit.sh $(bold)${VERSION}$(clr) by Yancharuk Alexander\n"

	return 0
}

# Function returns list of changed PHP files
get_commit_files() {
	git diff-tree --no-commit-id --name-only -r "$1" | grep -E '(.php$|.phtml)$'

	return $?
}

# Function for checking PHP syntax
check_syntax() {
	local result=0
	local output

	output="$(php -nl "$1" 2>&1)"

	# shellcheck disable=SC2181
	if [[ $? -eq 0 ]]; then
		status "SYNTAX: $1" OK
	else
		status "SYNTAX: $1" FAIL
		errors="$errors$(echo "$output" | grep "Parse error")\n"
		result=1
	fi

	return $result
}

# Function for checking PHP dumps
check_dumps() {
	local result=0
	local output
	local line
	local lines=0

	output="$(grep -ETn '(var_dump|var_export|print_r)' "$1" 2>&1)"

	if [[ -n "$output" ]]; then
		lines=$(echo "$output" | wc -l)
		status "DUMPS: $1" FAIL

		if [[ ${lines} -gt 1 ]]; then
			while read -r line; do
				dumps="${dumps}${1} on line ${line}\n"
			done < <(echo "$output")
		elif [[ ${lines} -eq 1 ]]; then
			dumps="${dumps}${1} on line ${output}\n"
		fi

		result=1
	else
		status "DUMPS: $1" OK
	fi

	return ${result}
}

# Function for checking git conflicts
check_conflicts() {
	local result=0
	local output
	local line
	local lines=0

	#debug "Git conflicts check $1"
	output="$(grep -En '(=======|<<<<<<<|>>>>>>>)' "$1" 2>&1)"

	if [[ -n "$output" ]]; then
		lines=$(echo "$output" | wc -l)
		status "CONFLICTS: $1" FAIL

		if [[ ${lines} -gt 1 ]]; then
			while read -r line; do
				conflicts="${conflicts}${1} on line $line\n"
			done < <(echo "$output")
		elif [[ ${lines} -eq 1 ]]; then
			conflicts="${conflicts}${1} on line $output\n"
		fi

		result=1
	else
		status "CONFLICTS: $1" OK
	fi

	return ${result}
}

# Function returns list of changed PHP files
get_php_files() {
	local result=0

	git diff --cached --name-only --diff-filter=ACMR | grep -E '(.php$|.phtml)$'

	return ${result}
}

# Function returns list of all changed files
get_files() {
	local result=0

	for file in $(git diff --cached --name-only --diff-filter=ACMR); do
	if [[ -f ${file} ]]; then
		echo "$file"
	fi
	done

	return ${result}
}

main() {
	check_dependencies grep date php git wc || exit 1

	local -r syntax_flag=$(git_config_bool check.php.syntax "$PROJECT_PATH")			|| exit 1
	local -r dump_flag=$(git_config_bool check.php.dumps "$PROJECT_PATH")					|| exit 1
	local -r conflict_flag=$(git_config_bool check.php.conflicts "$PROJECT_PATH")	|| exit 1
	local -r php_files=$(get_php_files)		|| exit 1
	local -r files=$(get_files)						|| exit 1
	local errors
	local dumps
	local conflicts

	[[ "$syntax_flag" ]] && for file in ${php_files}; do
		check_syntax "$file"
	done

	[[ "$dump_flag" ]] && for file in ${php_files}; do
		check_dumps	"$file"
	done

	[[ "$conflict_flag" ]] && for file in ${files}; do
		check_conflicts	"$file"
	done

	while read -r line; do
		error "$line"
	done < <(echo -en "$errors")

	while read -r line; do
		warning "$line"
	done < <(echo -en "$dumps")

	while read -r line; do
		error "$line"
	done < <(echo -en "$conflicts")

	if [[ -n "$errors" ]]; then
		exit 1
	fi

	if [[ -n "$conflicts" ]]; then
		exit 1
	fi
}
