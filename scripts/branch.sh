#!/bin/bash

if [ $# -ne 4 ];
    then echo "args required: source repo, source dir, target repo, target dir"
    exit 1
fi

# We will get our files from the source repo/dir.
sourceDir="$1"/"$2"

# We will copy these files to destination repo/dir
destDir="$3"/"$4"

# Create our destination dir in case it does not yet exist, because we cannot
# diff a directory that does not exist.
mkdir -p "$destDir"

# Check whether there is any difference between our source docs folder and our
# current copy, exiting early if there is no difference.
diff=$(git diff "$sourceDir" "$destDir" )
if [ -z "$diff" ];
    then
      echo "No difference in docs folder"
      exit 0

    else
      echo "Docs differ, syncing documents"
fi

# Copy everything from source to destination, replacing what's there.
cp -rf "$sourceDir"/*."$4" "$destDir"

# Create a branch for our change, commit changes and push branch.
branch=docs-"$sourceDir"
git branch "$branch"
./test-sync/scripts/commit.sh test-sync "update documentation"

git push --set-upstream origin "$branch"
