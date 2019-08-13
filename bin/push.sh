#!/bin/sh
# ( commit.sh... )

# add tag
read -p "Do you want to add tag? (y/n)" answer

case $answer in
  y)
    # show all tags
    git tag
    # add a new tag
    read -p "Tag Version: " tagVersion
    read -p "Tagging Message: " taggingMessage
    git tag -a $tagVersion -m "$taggingMessage"
    git push --tags
    ;;
  n)
    ;;
  *)
    ;;
esac

# push
git push
