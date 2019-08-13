#!/usr/bin/env bash

# Constants
ARROW='>'
# Paths
source "${HOME}/dotfiles/util/imports.sh"

greetings

report_header "$ARROW Updating Dotfiles..."
git pull origin master

report_header "$ARROW Updating Boosnote Files..."
cd $BOOSTNOTE
git pull origin master
