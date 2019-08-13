#!/bin/bash
# add
git add -A

# commit
read -p "Commit message: " commitMessage
git commit -m "$commitMessage"
