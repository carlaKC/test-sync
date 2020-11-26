#!/bin/bash

if [ $# -ne 2 ];
    then echo "target directory and commit message required"
    exit 1
fi

# Move into the target directory.
cd "$1" || exit 1

staged=$(git status)
if [ -z "$staged" ];
  then echo "nothing to commit"
  exit 0
fi

# Save our current git name/email so that we can reset if after we have
# committed as the actions bot. This is for local dev, so you don't bork your
# existing config.
me=$(git config --local user.name)
myEmail=$(git config --local user.email)

git add .
git config --local user.email "action@github.com"
git config --local user.name "Github Actions"
git commit -m "$2" || exit 1

# Push these changes to master.
git push || exit 1

# Reset our config values.
git config --local user.email "$myEmail"
git config --local user.name "$me"
