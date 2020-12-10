#!/bin/bash

if [ $# -ne 3 ];
    then echo "args required: source repo, source dir, target dir"
    exit 1
fi

# We will get our files from the source repo/dir.
sourceDir="$1"/"$2"

# We will copy these files to destination dir.
destDir="$3"

# Create our destination dir in case it does not yet exist, because we cannot
# diff a directory that does not exist.
mkdir -p "$destDir"

# Check whether there is any difference between our source docs folder and our
# current copy, exiting early if there is no difference.
diff=$( diff "$sourceDir" "$destDir" )
if [ -z "$diff" ];
    then
      echo "No difference in docs folder"
      exit 0

    else
      echo "Docs differ, syncing documents"
fi

# Copy everything from source to destination, replacing what's there.
cp -rf "$sourceDir" "$destDir"
rm -rf "$1"