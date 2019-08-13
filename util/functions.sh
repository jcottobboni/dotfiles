permit_execute_script () {
	chmod +x $DOTFILES_PATH/execute.sh
}

permit_src_scripts () {
	for SCRIPT in `ls $DOTFILES_PATH/src | grep sh`
	do
	  chmod +x $DOTFILES_PATH/src/$SCRIPT
	done
}

report_header() {
  echo -e "\n\033[1m$*\033[0m";
}

report_success() {
  echo -e " \033[1;32m✔\033[0m  $*";
}

report_install() {
  report_success "$1 $ARROW $2"
}

greetings(){
	h=`date +%H`
	if [ $h -lt 12 ]; then
	  report_header "$ARROW Good morning Mr. $USER "
	elif [ $h -lt 18 ]; then
	  report_header  "$ARROW Good afternoon Mr. $USER "
	else
	  report_header  "$ARROW Good evening Mr. $USER "
	fi
}
