#!/bin/sh

# --- Safety check
if [ -z "$GIT_DIR" ]; then
	echo "Don't run this script from the command line." >&2
	echo " (if you want, you could supply GIT_DIR then run" >&2
	echo " $0 <old_rev> <new_rev> <ref>)" >&2
	exit 1
fi

status=0

while read old_rev new_rev ref_name; do
	for script in `find $PWD/hooks/pre-receive.d/ -perm -100 -type f`; do
		${script} "$old_rev" "$new_rev" "$ref_name"
		if [ "$?" -ne 0 ]; then
			status=1
		fi
	done
done

exit ${status}