#!/usr/bin/env bash

# Pre-commit git-hook.
# Use for running QA jobs before commit:
#	- Check PHP syntax errors
#	- Check for unresolved git conflicts
#	- Warn about forgotten PHP dump-functions
#
# Depends on "bash-helpers" functions.
# @see https://github.com/nafigator/bash-helpers

PROJECT_PATH=$(dirname $(dirname $(dirname $(readlink -f "$0"))))

cd ${PROJECT_PATH}/vendor/nafigator
. bash-helpers/src/bash-helpers.sh
. php-qa-hooks/src/includes/pre-commit.inc.sh

cd - >/dev/null

VERSION=1.0.5
INTERACTIVE=$(git_config_bool check.php.colors ${PROJECT_PATH})

parse_options ${@}
PARSE_RESULT=$?

[[ ${PARSE_RESULT} = 1 ]] && exit 1;
[[ ${PARSE_RESULT} = 2 ]] && usage_help && exit 2;

main
