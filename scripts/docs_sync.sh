#!/bin/bash

if [ $# -ne 3 ];
    then echo "target directory, upstream and downstream repo required"
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
cp -rf "$upstreamDir"/* "$downstreamDir"

# Move into the downstream directory and commit our changes.
cd "$3" || exit 1

# Save our current git name/email so that we can reset if after we have
# committed as the actions bot. This is for local dev, so you don't bork your
# existing config.
me=$(git config --local user.name)
myEmail=$(git config --local user.email)

git add .
git config --local user.email "action@github.com"
git config --local user.name "Github Actions"
git commit -m "docsync: from $2/$1" || exit 1

# Push these changes to master.
git push || exit 1

# Reset our config values.
git config --local user.email "$myEmail"
git config --local user.name "$me"
