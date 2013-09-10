#!/usr/local/bin/bash

errors=""
php="/usr/local/bin/php"

old_rev=$1
new_rev=$2
ref_name=$3

zero="0000000000000000000000000000000000000000"
if [ "$old_rev" = "$zero" ]; then
	# Created new branch
	list=$(git diff-tree -r ${new_rev} | grep -e '\.php' -e '\.phtml')
elif [ "$new_rev" = "$zero" ]; then
	# Deleted branch
	exit 0
else
	list=$(git diff-tree -r ${old_rev}..${new_rev} | grep -e '\.php' -e '\.phtml')
fi

#echo "DEBUG \$list: $list"
# if commit not contain php-files -exit
if [ -z "$list" ]; then
	exit 0
fi

while read line; do
	read old_mode new_mode old_sha1 new_sha1 status name <<< ${line}
	if [ "$status" == "D" ]; then
		#echo "DEBUG: status equal D"
		continue
	fi

	output=$(git cat-file blob ${new_sha1} | ${php} -l 2>&1 >/dev/null)

	if [ "$?" -ne 0 ]; then
		output=$(echo ${output} | sed "s# - # $name #g")
		if [ "$errors" != "" ]; then
			errors="$errors\n$output"
		else
			errors="$output"
		fi
	fi
done <<< ${list}

if [ "$errors" != "" ]; then
	echo "Found php syntax errors: "
	echo
	echo -e ${errors}
	echo
	echo "FIX ERRORS BEFORE PUSH!"
	exit 1
fi
