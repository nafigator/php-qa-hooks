#!/usr/bin/env bash
#
# pre-commit.sh
#
# Check for PHP syntax errors and want about debug functions before commit
#
# Git Config Options
#	check.php.syntax : (type: boolean) enable|disable PHP syntax check
#	check.php.dumps  : (type: boolean) enable|disable check for var_dump|var_export functions
#
# Author:	Yancharuk Alexander <alex at itvault dot info>

DEBUG=;

# Function for bool values validation
get_config_bool() {
	local value=$(git config --get $1)
	local result=0

	if [[ ! -z "$value" && -z "$(echo "$value" | egrep '^(true|false)$')" ]]; then
		error "Git config option \"$1\" has not valid value!"
		result=1
	elif [ "$value" == 'true' ]; then
		echo 1
	fi

	return ${result}
}

# Function for error messages
error() {
	printf "[$(date +%F\ %T)] \033[0;31mERROR\033[0m: $@\n" >&2
}

# Function for informational messages
inform() {
	printf "[$(date +%F\ %T)] \033[0;32mINFO\033[0m: $@\n"
}

# Function for warning messages
warning() {
	printf "[$(date +%F\ %T)] \033[0;33mWARNING\033[0m: $@\n" >&2
}

# Function for debug messages
debug() {
	if [ ! -z "$DEBUG" ]; then
		printf "[$(date +%F\ %T.%N)] \033[0;32mDEBUG\033[0m: $@\n";
	fi
}

# Check for utils used in script
check_dependencies() {
	local commands='grep egrep date php git'
	local result=0
	local i=0

	for i in ${commands}; do
		command -v ${i} >/dev/null 2>&1
		if [ $? -eq 0 ]; then
			debug "Check $i ... OK"
		else
			error "Check $i ... FAIL"
			result=1
		fi
	done

	return ${result}
}

# Function for checking PHP syntax
check_syntax() {
	local result=0
	local output=''

	debug "Syntax check $1"
	output="$(php -l $1 2>&1)"

	if [ $? -eq 0 ]; then
		inform "Syntax check $1 ... OK"
	else
		ERRORS="$ERRORS$(printf "$output" | grep "Parse error")\n"
		result=1
	fi

	return ${result}
}

# Function for checking PHP dumps
check_dumps() {
	local result=0
	local output=''

	debug "Dumps check $1"
	output="$(egrep -n '(var_dump|var_export)' $1)"

	if [ ! -z "$output" ]; then
		DUMPS="$DUMPS$(printf "$1 on line $output")\n"
	else
		inform "PHP dumps check $1 ... OK"
	fi

	return ${result}
}

# Function returns list of changed PHP files
get_files() {
	local result=0

	git diff --cached --name-only --diff-filter=ACMR | egrep '(.php$|.phtml)$'

	return ${result}
}

check_dependencies || exit 1

SYNTAX_FLAG=$(get_config_bool check.php.syntax)	&& debug 'SYNTAX_FLAG value is valid'	|| exit 1
DUMP_FLAG=$(get_config_bool check.php.dumps)	&& debug 'DUMP_FLAG value is valid'		|| exit 1
FILES=$(get_files)								&& debug "FILES: \n${FILES}"			|| exit 1
ERRORS=''
DUMPS=''

for file in ${FILES}; do
	debug "Processing $file"
	[ "$SYNTAX_FLAG" ]	&& check_syntax ${file}
	[ "$DUMP_FLAG" ]	&& check_dumps	${file}
done

printf "$ERRORS" | while IFS="\n" read -r line; do
	error "$line"
done

printf "$DUMPS" | while IFS="\n" read -r line; do
	warning "$line"
done

if [ ! -z "$ERRORS" ]; then
	exit 1
fi
