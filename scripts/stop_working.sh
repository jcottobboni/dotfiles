#!/usr/bin/env bash

# Constants
ARROW='>'
# Paths
source "${HOME}/dotfiles/util/imports.sh"

greetings

report_header "$ARROW Sending Dotfiles to repo..."
git add --all
git commit -a -m 'Add Updates'
git push origin master

report_header "$ARROW Sending Boosnote Files to repo..."
cd $BOOSTNOTE
git add --all
git commit -a -m 'Add Updates'
git push origin master
