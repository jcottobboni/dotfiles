#!/usr/bin/env bash

# Constants
ARROW='>'
# Paths

cd "${HOME}/dotfiles"
source "${HOME}/dotfiles/util/imports.sh"

greetings

report_header "$ARROW Sending Dotfiles to repo..."
git add --all
git commit -a -m 'Add Updates'
git push origin master

report_header "$ARROW Sending Private Dotfiles to repo..."
cd $PRIVATE_DOTFILES
git add --all
git commit -a -m 'Add Updates'
git push origin master

report_header "$ARROW Sending Boosnote Files to repo..."
cd $BOOSTNOTE
git add --all
git commit -a -m 'Add Updates'
git push origin master


while true; do
	rand=$(shuf -i 2600-2700 -n 1)
	echo -n -e '   \u'$rand
	sleep 1
done
