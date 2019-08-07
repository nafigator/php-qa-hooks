#!/usr/bin/env bash

usage_help() {
	printf "$(bold)Usage:$(clr)
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
  or disable check by parameters.

"

	return 0
}

print_version() {
	printf "pre-commit.sh $(bold)${VERSION}$(clr) by Yancharuk Alexander\n\n"

	return 0
}

cleanup() {
	unset VERSION PARSE_RESULT
}

# Function returns list of changed PHP files
get_commit_files() {
	git diff-tree --no-commit-id --name-only -r $1 | egrep '(.php$|.phtml)$'

	return $?
}

# Function for checking PHP syntax
check_syntax() {
	local result=0
	local output=''

	#debug "Syntax check $1"
	output="$(php -l $1 2>&1)"

	if [[ $? -eq 0 ]]; then
		status "SYNTAX: $1" OK
	else
		status "SYNTAX: $1" FAIL
		errors="$errors$(printf "$output")\n"
		result=1
	fi

	return ${result}
}

# Function for checking PHP dumps
check_dumps() {
	local result=0
	local output=''
	local line=''
	local lines=0

	output="$(egrep -Tn '(var_dump|var_export|print_r)' $1 2>&1)"

	if [[ ! -z "$output" ]]; then
		lines=$(printf "$output\n" | wc -l)
		status "DUMPS: $1" FAIL

		if [[ ${lines} -gt 1 ]]; then
			while read line; do
				dumps="$dumps$(printf "$1 on line $line")\n"
			done < <(printf "$output\n")
		elif [[ ${lines} -eq 1 ]]; then
			dumps="$dumps$(printf "$1 on line $output")\n"
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
	local output=''
	local line=''
	local lines=0

	#debug "Git conflicts check $1"
	output="$(egrep -n '(=======|<<<<<<<|>>>>>>>)' $1 2>&1)"

	if [[ ! -z "$output" ]]; then
		lines=$(printf "$output\n" | wc -l)
		status "CONFLICTS: $1" FAIL

		if [[ ${lines} -gt 1 ]]; then
			while read line; do
				conflicts="$conflicts$(printf "$1 on line $line")\n"
			done < <(printf "$output\n")
		elif [[ ${lines} -eq 1 ]]; then
			conflicts="$conflicts$(printf "$1 on line $output")\n"
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

	git diff --cached --name-only --diff-filter=ACMR | egrep '(.php$|.phtml)$'

	return ${result}
}

# Function returns list of all changed files
get_files() {
	local result=0

	for file in $(git diff --cached --name-only --diff-filter=ACMR); do
	if [[ -f ${file} ]]; then
		echo ${file}
	fi
	done

	return ${result}
}

main() {
	local status_length=60

	check_dependencies grep egrep date php git wc || exit 1

	readonly local syntax_flag=$(get_config_bool check.php.syntax)		|| exit 1
	readonly local dump_flag=$(get_config_bool check.php.dumps)			|| exit 1
	readonly local conflict_flag=$(get_config_bool check.php.conflicts)	|| exit 1
	readonly local php_files=$(get_php_files)							|| exit 1
	readonly local files=$(get_files)									|| exit 1
	local errors=''
	local dumps=''
	local conflicts=''

	[[ "$syntax_flag" ]] && for file in ${php_files}; do
		check_syntax ${file}
	done

	[[ "$dump_flag" ]] && for file in ${php_files}; do
		check_dumps	${file}
	done

	[[ "$conflict_flag" ]] && for file in ${files}; do
		check_conflicts	${file}
	done

	while read line; do
		error "$line"
	done < <(printf "$errors")

	while read line; do
		warning "$line"
	done < <(printf "$dumps")

	while read line; do
		error "$line"
	done < <(printf "$conflicts")

	if [[ ! -z "$errors" ]]; then
		exit 1
	fi

	if [[ ! -z "$conflicts" ]]; then
		exit 1
	fi
}
