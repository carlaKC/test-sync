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
for file in "$sourceDir"/*
do
    # Get the file name from the path.
    fname=$(basename "$file")

    diff=$( diff "$file" "$destDir"/"$fname" )
    if [ -n "$diff" ];
        then
          echo "Doc: $fname differs, syncing documents"

          # Set an output that the rest of our workflow can use to determine
          # whether to proceed.
          echo ::set-output name=have_diff::"true"
          break
        else
          echo "No diff?"
    fi
done

# Copy everything from source to destination, replacing what's there.
cp -rf "$sourceDir"/* "$destDir"