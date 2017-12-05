#!/usr/bin/env bash
#
# pre-commit.sh
#
# Check for PHP syntax errors and warn about debug functions before commit
#
# Git Config Options
#	check.php.syntax : (type: boolean) enable|disable PHP syntax check
#	check.php.dumps  : (type: boolean) enable|disable check for var_dump|var_export functions
#
# Author:	Yancharuk Alexander <alex at itvault dot info>

# https://en.wikipedia.org/wiki/ANSI_escape_code
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
GRAY="\e[38;5;242m"
BOLD="\e[1m"
CLR="\e[0m"
DEBUG=

# Function for bool values validation
get_config_bool() {
	local value=$(git config --bool $1)
	local result=0

	if [[ ! -z "$value" && -z "$(echo "$value" | egrep '^(true|false)$')" ]]; then
		error "Git config option \"$1\" has not valid value!"
		result=1
	elif [ "$value" == 'true' ]; then
		echo 1
	fi

	return ${result}
}


format_date() {
	printf "$GRAY$(date +'%Y-%m-%d %H:%M:%S')$CLR"

	return 0
}

# Function for error messages
error() {
	printf "[$(format_date)]: ${RED}ERROR:$CLR $@\n" >&2
}

# Function for informational messages
inform() {
	printf "[$(format_date)]: ${GREEN}INFO:$CLR $@\n"
}

# Function for warning messages
warning() {
	printf "[$(format_date)]: ${YELLOW}WARNING:$CLR $@\n" >&2
}

# Function for debug messages
debug() {
	[ ! -z ${DEBUG} ] && printf "[$(format_date)]: ${GREEN}DEBUG:$CLR $@\n"
}

# Function for operation status
#
# Usage: status MESSAGE STATUS
# Examples:
# status 'Upload scripts' $?
# status 'Run operation' OK
status() {
	if [ -z "$1" ] || [ -z "$2" ]; then
		error "Not found required parameters!"
		return 1
	fi

	local result=0

	if [ $2 = 'OK' ]; then
		printf "[$(format_date)]: %-60b[$GREEN%s$CLR]\n" "$1" "OK"
	elif [ $2 = 'FAIL' ]; then
		printf "[$(format_date)]: %-60b[$RED%s$CLR]\n" "$1" "FAIL"
		result=1
	elif [ $2 = 0 ]; then
		printf "[$(format_date)]: %-60b[$GREEN%s$CLR]\n" "$1" "OK"
	elif [ $2 > 0 ]; then
		printf "[$(format_date)]: %-60b[$RED%s$CLR]\n" "$1" "FAIL"
		result=1
	fi

	return ${result}
}

# Function for status on some command in debug mode only
status_dbg() {
	[ -z ${DEBUG} ] && return 0

	local result=0

	if [ $2 = 'OK' ]; then
		printf "[$(format_date)]: ${GREEN}DEBUG:$CLR %-53b[$GREEN%s$CLR]\n" "$1" "OK"
	elif [ $2 = 'FAIL' ]; then
		printf "[$(format_date)]: ${GREEN}DEBUG:$CLR %-53b[$RED%s$CLR]\n" "$1" "FAIL"
	elif [ $2 = 0 ]; then
		printf "[$(format_date)]: ${GREEN}DEBUG:$CLR %-53b[$GREEN%s$CLR]\n" "$1" "OK"
	elif [ $2 > 0 ]; then
		printf "[$(format_date)]: ${GREEN}DEBUG:$CLR %-53b[$RED%s$CLR]\n" "$1" "FAIL"
		result=1
	fi

	return ${result}
}

# Function for checking script dependencies
check_dependencies() {
	local result=0

	for i in ${@}; do
		command -v ${i} >/dev/null 2>&1
		if [ $? -eq 0 ]; then
			status_dbg "DEPENDENCY: $i" OK
		else
			warning "$i command not available"
			result=1
		fi
	done

	debug "check_dependencies() result: $result"

	return ${result}
}

# Function for checking PHP syntax
check_syntax() {
	local result=0
	local output=''

	debug "Syntax check $1"
	output="$(php -l $1 2>&1)"

	if [ $? -eq 0 ]; then
		status "${GREEN}SYNTAX:${CLR} $1" OK
	else
		status "${GREEN}SYNTAX:${CLR} $1" FAIL
		ERRORS="$ERRORS$(printf "$output" | grep "Parse error")\n"
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

	output="$(egrep -n '(var_dump|var_export|print_r)' $1)"

	if [ ! -z "$output" ]; then
		lines=$(printf "$output\n" | wc -l)
		status "${GREEN}DUMPS:${CLR} $1" FAIL

		if [ ${lines} -gt 1 ]; then
			while read line; do
				DUMPS="$DUMPS$(printf "$1 on line $line")\n"
			done < <(printf "$output\n")
		elif [ ${lines} -eq 1 ]; then
			DUMPS="$DUMPS$(printf "$1 on line $output")\n"
		fi
	else
		status "${GREEN}DUMPS:${CLR} $1" OK
	fi

	return ${result}
}

# Function for checking git conflicts
check_conflicts() {
	local result=0
	local output=''
	local line=''
	local lines=0

	debug "Git conflicts check $1"
	output="$(egrep -n '(=======|<<<<<<<|>>>>>>>)' $1)"

	if [ ! -z "$output" ]; then
		lines=$(printf "$output\n" | wc -l)
		status "${GREEN}CONFLICTS:${CLR} $1" FAIL

		if [ ${lines} -gt 1 ]; then
			while read line; do
				CONFLICTS="$CONFLICTS$(printf "$1 on line $line")\n"
			done < <(printf "$output\n")
		elif [ ${lines} -eq 1 ]; then
			CONFLICTS="$CONFLICTS$(printf "$1 on line $output")\n"
		fi
	else
		status "${GREEN}CONFLICTS:${CLR} $1" OK
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

	git diff --cached --name-only --diff-filter=ACMR

	return ${result}
}

check_dependencies grep egrep date php git wc || exit 1

SYNTAX_FLAG=$(get_config_bool check.php.syntax)			|| exit 1
DUMP_FLAG=$(get_config_bool check.php.dumps)			|| exit 1
CONFLICT_FLAG=$(get_config_bool check.php.conflicts)	|| exit 1
PHP_FILES=$(get_php_files)								|| exit 1
FILES=$(get_files)										|| exit 1
ERRORS=''
DUMPS=''
CONFLICTS=''

[ "$SYNTAX_FLAG" ] && for file in ${PHP_FILES}; do
	check_syntax ${file}
done

[ "$DUMP_FLAG" ] && for file in ${PHP_FILES}; do
	check_dumps	${file}
done

[ "$CONFLICT_FLAG" ] && for file in ${FILES}; do
	check_conflicts	${file}
done

while read line; do
	error "$line"
done < <(printf "$ERRORS")

while read line; do
	warning "$line"
done < <(printf "$DUMPS")

while read line; do
	error "$line"
done < <(printf "$CONFLICTS")

if [ ! -z "$ERRORS" ]; then
	exit 1
fi
