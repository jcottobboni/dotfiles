permit_execute_script () {
	chmod +x $DOTFILES_PATH/execute.sh
}

permit_src_scripts () {
	for SCRIPT in `ls $DOTFILES_PATH/src | grep sh`
	do
	  chmod +x $DOTFILES_PATH/src/$SCRIPT
	done
}
