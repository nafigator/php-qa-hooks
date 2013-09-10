#!/usr/local/bin/bash
#
# An example hook script to prepare a packed repository for use over
# dumb transports.
#
# To enable this hook, rename this file to "post-update".

unset GIT_DIR
umask 002
cd /path/to/clone/dir
echo "Test environment syncronization"
git pull
status=$?
if [ $status == 0 ]; then
    echo "Success!"
fi