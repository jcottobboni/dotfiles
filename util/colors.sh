DEFAULT_COLOR='\e[0m'

DEFAULT_STYLE='\e[21m\e[22m\e[24m\e[27m'
BOLD_STYLE='\e[1m'

default_message () {
	if [ -n "$1" ] && [ -n "$2" ]
	then
		SPACING="\n"
	else
		SPACING=""
	fi

	echo -e "$BOLD_STYLE$1$SPACING$DEFAULT_STYLE$2$3"
}
