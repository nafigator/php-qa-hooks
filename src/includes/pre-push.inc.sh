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

"

	return 0
}

print_version() {
	printf "pre-push.sh $(bold)${VERSION}$(clr) by Yancharuk Alexander\n\n"

	return 0
}

# Function returns list of changed PHP files
get_commit_files() {
	git diff-tree --no-commit-id --name-only -r $1 | egrep '(.php$|.phtml)$'

	return $?
}
