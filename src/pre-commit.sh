#!/usr/bin/env bash

PROJECT_PATH=$(dirname $(dirname $(dirname $(dirname $(dirname $(readlink -f "$0"))))))
VERSION=0.2.0

cd ${PROJECT_PATH}/vendor/nafigator
. bash-helpers/src/bash-helpers.sh
. git-hooks/src/includes/pre-commit.inc.sh

cd - >/dev/null

parse_options ${@}
PARSE_RESULT=$?

[ ${PARSE_RESULT} = 1 ] && exit 1;
[ ${PARSE_RESULT} = 2 ] && usage_help && exit 2;

check_dependencies grep egrep date php git wc || exit 1

main
