#!/bin/bash

CURRENT_DIR=`pwd`
cd ~/dotfiles
. util/imports.sh
. src/$1.sh
cd $CURRENT_DIR
