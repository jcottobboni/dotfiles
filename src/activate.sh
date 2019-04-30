default_message "ACTIVATE" "Ativando as suas configurações" "\n"

for FILE in ${FILES_TO_INSTALL[*]}
do
	if [ -f $DOTFILES_FILES_PATH/$FILE ]
	then
		default_message "" "$FILE"
		if [ -f ~/$FILE ]
		then
			rm ~/$FILE
		else
			mkdir -p ~/$FILE
			rm -r ~/$FILE
		fi
		ln -s $DOTFILES_FILES_PATH/$FILE ~/$FILE
	fi
done

sudo chmod +x $DOTFILES_FILES_PATH/.config/i3/lock.sh
sudo chmod +x $DOTFILES_FILES_PATH/.config/polybar/launch.sh
cp $DOTFILES_FILES_PATH/.config/i3/wallpaper.jpg ~/.config/i3
cp $DOTFILES_FILES_PATH/Xresources ~/
i3-msg restart
