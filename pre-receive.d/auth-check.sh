#!/usr/local/bin/bash

# --- Command line
old_rev=$1
new_rev=$2
ref_name=$3

#echo "DEBUG: $old_rev $new_rev $ref_name"

# Branches not allowable for delete
dev_branches=(refs/heads/development refs/heads/production)

# Secure branches
sec_branches=(refs/heads/development refs/heads/production)

# Authorized users
sec_users=('UserName 1' 'UserName 2' 'UserName 3' 'UserName 4')

# --- Safety check
if [ -z "$GIT_DIR" ]; then
	echo "Don't run this script from the command line." >&2
	echo " (if you want, you could supply GIT_DIR then run" >&2
	echo "  $0 <ref> <old_rev> <new_rev>)" >&2
	exit 1
fi

if [ -z "$old_rev" -o -z "$new_rev" -o -z "$ref_name" ]; then
	echo "Usage: $0 <old_rev> <new_rev> <ref_name> " >&2
	exit 1
fi

# --- Config
allowunannotated=$(git config --bool hooks.allowunannotated)
allowdeletedevbranch=$(git config --bool hooks.allowdeletedevbranch)
denycreatebranch=$(git config --bool hooks.denycreatebranch)
allowdeletetag=$(git config --bool hooks.allowdeletetag)
allowmodifytag=$(git config --bool hooks.allowmodifytag)
allowwildtag=$(git config --bool hooks.allowwildtag)

# --- Check types
# if $new_rev is 0000...0000, it's a commit to delete a ref.
zero="0000000000000000000000000000000000000000"
if [ "$new_rev" = "$zero" ]; then
	new_rev_type=delete
else
	new_rev_type=$(git cat-file -t ${new_rev})
fi

case "$ref_name","$new_rev_type" in
	refs/tags/*,commit)
		# un-annotated tag
		short_ref_name=${ref_name##refs/tags/}
		if [ "$allowunannotated" != "true" ]; then
			echo
			echo "The un-annotated tag, $short_ref_name, is not allowed in this repository" >&2
			echo "Use 'git tag [ -a | -s ]' for tags you want to propagate." >&2
			echo
			exit 1
		fi
		;;
	refs/tags/*,delete)
		# delete tag
		# TESTED!
		if [ "$allowdeletetag" != "true" ]; then
			echo
			echo "Deleting a tag is not allowed in this repository" >&2
			echo
			exit 1
		fi
		;;
	refs/tags/*,tag)
		# annotated tag
		if [ "$allowwildtag" != "true" ] && ./hooks/check_tag -r ${ref_name} > /dev/null 2>&1; then
			echo
			echo "Tag '$ref_name' does not match the naming constraints." >&2
			echo "Tags must follow the 'x.y-z' pattern, where x, y, and z are numeric characters." >&2
			echo
			exit 1
		fi
		# TESTED!
		if [ "$allowmodifytag" != "true" ] && git rev-parse ${ref_name} > /dev/null 2>&1; then
			echo
			echo "Tag '$ref_name' already exists." >&2
			echo "Modifying a tag is not allowed in this repository." >&2
			echo
			exit 1
		fi
		;;
	refs/heads/*,commit)
		# branch
		# TESTED!
		if [ "$old_rev" = "$zero" -a "$denycreatebranch" = "true" ]; then
			echo
			echo "Creating a branch is not allowed in this repository" >&2
			echo
			exit 1
		fi

		# new commit
		# Check if branch is secure
		# TESTED!
		case ${sec_branches[@]} in *${ref_name}*)
			#echo "DEBUG: Entering into security cycle"
			# Save committer and author into variables
			commit_prefs=$(git log -1 --pretty=format:'%an:%cn' ${new_rev})
			#echo "DEBUG \$commit_prefs: $commit_prefs"
			IFS=":" read author committer <<< "$commit_prefs"
			#echo "DEBUG: $author : $committer"

			# if committer and author not in allowed persons - exit
			case ${sec_users[@]} in
				*${author}*)
					#echo "DEBUG: authorisation successful"
				;;
				*)
					branch_name=`echo ${ref_name:11}`
					echo
					echo "You're not allowed to push in $branch_name branch" >&2
					echo
					exit 1
				;;
			esac

			# if committer and author not equal - exit
			if [ "$author" != "$committer" ]; then
				echo
				echo "You're not author of pushed commits. This is restricted" >&2
				echo
				exit 1
			fi
			;;
		esac
		;;
	refs/heads/*,delete)
		# delete branch
		# TESTED!
		if [ "allowdeletedevbranch" != "true" ]; then
			case ${dev_branches[@]} in *${ref_name}*)
				branch_name=`echo ${ref_name:11}`
				echo
				echo "Deleting the $branch_name branch is not allowed in this repository" >&2
				echo
				exit 1
			;;
			esac
		fi
		;;
	refs/remotes/*,commit)
		# tracking branch
		;;
	refs/remotes/*,delete)
		# delete tracking branch
		if [ "allowdeletedevbranch" != "true" ]; then
			echo
			echo "Deleting a tracking branch is not allowed in this repository" >&2
			echo
			exit 1
		fi
		;;
	*)
		# Anything else (is there anything else?)
		echo
		echo "DEBUG: $old_rev $new_rev $ref_name $new_rev_type"
		echo "Update hook: unknown type of update to ref $ref_name of type $new_rev_type" >&2
		echo
		exit 1
		;;
esac

# --- Finished
exit 0