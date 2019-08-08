#!/usr/bin/env bash

PROJECT_PATH=$(dirname $(dirname $(dirname $(readlink -f "$0"))))

cd ${PROJECT_PATH}/vendor/nafigator
. bash-helpers/src/bash-helpers.sh
. php-qa-hooks/src/includes/pre-commit.inc.sh

cd - >/dev/null

VERSION=0.6.3
INTERACTIVE=$(get_config_bool check.php.colors)

parse_options ${@}
PARSE_RESULT=$?

[[ ${PARSE_RESULT} = 1 ]] && exit 1;
[[ ${PARSE_RESULT} = 2 ]] && usage_help && exit 2;

main
