#!/usr/bin/env bash

# Pre-push git-hook.
# Use for running QA jobs before push:
#	- Check PHP code style
#	- Run PHPUnit tests (off by default)
#
# Depends on "bash-helpers" functions.
# @see https://github.com/nafigator/bash-helpers

PROJECT_PATH=$(dirname $(dirname $(dirname $(readlink -f "$0"))))
Z40=0000000000000000000000000000000000000000

cd ${PROJECT_PATH}/vendor/nafigator
. bash-helpers/src/bash-helpers.sh
. php-qa-hooks/src/includes/pre-push.inc.sh

VERSION=1.0.3
INTERACTIVE=$(git_config_bool check.php.colors ${PROJECT_PATH})

parse_options ${@}
PARSE_RESULT=$?

shift $((OPTIND-1))

[[ ${PARSE_RESULT} = 1 ]] && exit 1
[[ ${PARSE_RESULT} = 2 ]] && usage_help && exit 2

main ${@}
