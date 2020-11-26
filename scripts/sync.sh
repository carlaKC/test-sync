#!/bin/bash

if [ $# -ne 4 ];
    then echo "target directory, upstream + downstream repo required, and file extension required"
    exit 1
fi

# We will get our files from the upstream/path provided.
upstreamDir="$2"/"$1"

# We will copy these files to downstream/upstream/path
downstreamPath="$2"/"$1"
downstreamDir="$3"/"$downstreamPath"

# Create our downstream dir in case it does not yet exist, because we cannot
# diff a directory that does not exist.
mkdir -p "$downstreamDir"

# Check whether there is any difference between our upstream docs folder and our
# current copy, exiting early if there is no difference.
diff=$(git diff "$upstreamDir" "$downstreamDir" )
if [ -z "$diff" ];
    then
      echo "No difference in docs folder"
      exit 0

    else
      echo "Docs differ, syncing documents"
fi

# Copy everything from upstream to downstream, replacing what's there.
cp -rf "$upstreamDir"/*."$4" "$downstreamDir"
