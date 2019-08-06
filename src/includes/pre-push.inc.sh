#!/usr/bin/env bash

usage_help() {
	printf "${BOLD}Usage:${CLR}
  pre-push.sh [OPTIONS...]

${BOLD}Options:${CLR}
  -v, --version              Show script version
  -h, --help                 Show this help message
  -d, --debug                Run program in debug mode

${BOLD}Description:${CLR}
  Git-хук предназначен для проверки стилей перед отправкой коммитов в репозиторий.
  В данный момент производится проверка на соответствие ${BOLD}PSR2${CLR} стандарту:

${BOLD}WWW:${CLR}
  https://www.php-fig.org/psr/psr-2

"

	return 0
}

print_version() {
	printf "pre-push.sh ${BOLD}${VERSION}${CLR} by Yancharuk Alexander\n\n"

	return 0
}

cleanup() {
    unset VERSION status_length PARSE_RESULT z40
}

# Function returns list of changed PHP files
get_commit_files() {
	git diff-tree --no-commit-id --name-only -r $1 | egrep '(.php$|.phtml)$'

	return $?
}
