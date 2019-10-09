#!/usr/bin/env bash

# Private
_did_backup=
_copy_count=0
_link_count=0

# Constants
ARROW='>'
INSTALLDIR=$(pwd)
# Paths
dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
backup_dir="$dotfiles_dir/backups/$(date +%s)"

################################################################################
# File Management
################################################################################

get_src_path() {
  echo "$dotfiles_dir/files/$1"
}

get_dest_path() {
  echo "$HOME/.$1"
}

backup_file() {
  local file=$1
  _did_backup=1

  [[ -d $backup_dir ]] || mkdir -p "$backup_dir"
  mv "$file" "$backup_dir"
}

clone_repo() {
  if [[ ! -d "$2" ]]; then
    mkdir -p $(dirname $2)
    git clone --recursive "$1" "$2"
  fi
}

file_exists() {
  [[ -f "$1" ]] || [[ -d "$1" ]]
}

files_are_same() {
  [[ ! -L "$2" ]] && cmp --silent "$1" "$2"
}

files_are_linked() {
  if [[ ! -L "$2" ]] || [[ $(readlink "$2") != "$1" ]]; then
    return 1
  fi
}

copy_file() {
  local src_file
  local dest_file

  src_file=$(get_src_path "$1")
  dest_file=$(get_dest_path "$1")

  if ! files_are_same "$src_file" "$dest_file"; then
    file_exists "$dest_file" && backup_file "$dest_file"
    cp "$src_file" "$dest_file"
    _copy_count=$((_copy_count + 1))
    report_install "$src_file" "$dest_file"
  fi
}

link_file() {
  local src_file
  local dest_file

  src_file=$(get_src_path "$1")
  dest_file=$(get_dest_path "$1")

  if ! files_are_linked "$src_file" "$dest_file"; then
    file_exists "$dest_file" && backup_file "$dest_file"
    ln -sf "$src_file" "$dest_file"
    _link_count=$((_link_count + 1))
    report_install "$src_file" "$dest_file"
  fi
}

################################################################################
# Logging
################################################################################

report_header() {
  echo -e "\n\033[1m$*\033[0m";
}

report_success() {
  echo -e " \033[1;32m✔\033[0m  $*";
}

report_install() {
  report_success "$1 $ARROW $2"
}

################################################################################
# CLI
################################################################################

parse_args() {
  while :; do
    case $1 in
      -h|--help)
        show_help
        exit
        ;;
      --skip-intro)
          no_introduction=1
          skip_intro=1
          ;;
      --skip-dependencies)
          skip_dependencies=1
          ;;
      --)
          shift
          break
          ;;
      -?*)
          printf 'Unknown option: %s\n' "$1" >&2
          exit
          ;;
      *)
          break
    esac

    shift
  done
}

show_help() {
  echo "install.sh"
  echo
  echo "Usage: ./install.sh [options]"
  echo
  echo "Options:"
  echo "  --with-system  Run system-specific scripts (homebrew, install apps, etc.)"
  echo "  --skip-intro   Skip the ASCII art introduction when running"
}

show_intro() {
  echo "     _               ___ _ _             "
  echo "    | |       _     / __|_) |            "
  echo "  __| | ___ _| |_ _| |__ _| | _____  ___ "
  echo " / _  |/ _ (_   _|_   __) | || ___ |/___)"
  echo "( (_| | |_| || |_  | |  | | || ____|___ |"
  echo " \____|\___/  \__) |_|  |_|\_)_____|___/ "
  echo "                       by: jcottobboni   "
}

apt_update_upgrade() {
  echo "Updating Ubuntu..."
  sudo apt update && sudo apt upgrade && apt dist-upgrade
}

apt_intall_git() {
  which git &> /dev/null
  if [[ $? -ne 0 ]]; then
    echo "Git install..."
    sudo apt-get install git -y
  fi

  echo "Dotfiles update..."
  git pull origin master
}

create_projects_folder() {
  if [ ! -s ${HOME}/projects ]; then
    report_header "$ARROW Creating projects folder "
    source "${INSTALLDIR}/config.sh"
    echo "Creating folder ${PROJECTS}"
    mkdir ${PROJECTS}
  fi
}

generate_ssh_key() {
  if [ ! -s ${HOME}/.ssh/id_rsa.pub ]; then
    report_header "$ARROW Generating SSH Key "
    ssh-keygen -o -t rsa -b 4096 -C "$EMAIL"
  fi
}

apt_install_dev_dependencies() {
  echo "Installing dependencies..."
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

  sudo apt-get update
  sudo apt-get install arandr feh gnome-screenshot cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev \
  libxcb-image0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen xcb-proto libxcb-xrm-dev i3-wm \
  libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev i3lock scrot imagemagick xautolock compton \
  git-core curl htop zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev i3 cargo \
  libxslt1-dev software-properties-common libffi-dev nodejs yarn -y
  sudo apt install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev \
  libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev \
  libxkbcommon-x11-dev autoconf xutils-dev libtool rofi gdebi -y
  sudo apt install ruby-colorize -y
  sudo gem install colorls
  sudo apt-get instal cowsay fortunes fortunes-br
}

apt_install_bat() {
  if ! [ -x "$(command -v bat)" ]; then
    echo "Installing Bat a cat with wings..."
    cargo install bat
  fi
}

apt_install_cmake() {
  if ! [ -x "$(command -v cmake)" ]; then
    echo "Installing Cmake..."
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository ppa:george-edison55/cmake-3.x -y
    sudo apt-get update -y
    sudo apt-get install cmake -y
    sudo apt-get upgrade -y
  fi
}

apt_install_etcher() {
  if ! [ -x "$(command -v balena-etcher)" ]; then
    echo "Installing balena..."
     echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list -y
     sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
     sudo apt update && sudo apt install balena-etcher-electron
  fi
}

apt_install_skype() {
  if ! [ -x "$(command -v skypeforlinux)" ]; then
    echo "Installing Skype..."
    sudo apt install apt-transport-https -y
    wget -q -O - https://repo.skype.com/data/SKYPE-GPG-KEY | sudo apt-key add -
    echo "deb https://repo.skype.com/deb stable main" | sudo tee /etc/apt/sources.list.d/skypeforlinux.list
    sudo apt-get update
    sudo apt-get install skypeforlinux
  fi
}

apt_install_terminator() {
  if ! [ -x "$(command -v terminator)" ]; then
    echo "Installing Terminator..."
    sudo add-apt-repository ppa:gnome-terminator -y
    sudo apt-get update
    sudo apt-get install terminator -y
  fi
}

apt_install_zsh() {
  if ! [ -x "$(command -v zsh)" ]; then
     echo "Installing zsh..."
     sudo apt-get update
     sudo apt-get install zsh -y
     zsh --version
     whereis zsh
     sudo usermod -s /usr/bin/zsh $(whoami)
  fi
}

apt_install_oh_my_zsh() {
  if [ ! -s ${HOME}/.oh-my-zsh ]; then
    echo "Installing oh my zsh..."
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
  fi
}

apt_install_powerline_fonts_theme() {
  if [ ! -s ${HOME}/.oh-my-zsh/custom/themes/powerlevel9k ]; then
    echo "Installing i9 powerline theme..."
    git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
  fi
}

apt_install_zsh_autosuggestions() {
  if [ ! -s ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  fi
}

apt_install_zsh_syntax_highlighting() {
  if [ ! -s ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  fi
}

apt_install_rbenv() {
  if ! [ -x "$(command -v rbenv)" ]; then
    echo "Installing Rbenv..."
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(rbenv init -)"' >>  ~/.zshrc
  fi
}

apt_install_ruby_build() {
  if [ ! -s ${HOME}/.rbenv/plugins/ruby-build ]; then
    echo "Installing Ruby build..."
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >>  ~/.zshrc
  fi
}

apt_install_ruby() {
  echo "Installing Rubu 2.6.1..."
  rbenv install 2.6.1
  rbenv global 2.6.1
  ruby -v
}

apt_install_bundler() {
  echo "Installing Bundler..."
  gem install bundler
  rbenv rehash
}

apt_install_nodejs() {
  if ! [ -x "$(command -v nodejs)" ]; then
    echo "Installing NodeJs..."
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
}

apt_install_rails() {
  echo "Installing Rails..."
  gem install rails -v 5.2.2
  rbenv rehash
  rails -v
  gem install lolcat
}

apt_install_postgressql() {
    if ! [ -x "$(command -v psql)" ]; then
      echo "Installing Postgres..."
      sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
      wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
      sudo apt-get update
      sudo apt-get install postgresql-common -y
      sudo apt-get install postgresql-9.6 libpq-dev -y
      sudo -u postgres bash -c "psql -c \"CREATE USER $USER SUPERUSER INHERIT CREATEDB CREATEROLE;\""
      # I use this password as an example for tutorials, replace it with a secure one
      sudo -u postgres bash -c "psql -c \"  ALTER USER $USER PASSWORD 'abissal';\""
    fi
}

apt_install_docker() {
  source config.sh
  # Don't run this as root as you'll not add your user to the docker group
  sudo apt update
  sudo apt install apt-transport-https ca-certificates software-properties-common curl
  # sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  # echo deb https://apt.dockerproject.org/repo ubuntu-$(lsb_release -c | awk '{print $2}') main | sudo tee /etc/apt/sources.list.d/docker.list
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update
  sudo apt install -y linux-image-extra-$(uname -r)
  sudo apt purge lxc-docker docker-engine docker.io
  sudo rm -rf /etc/default/docker
  sudo apt install -y docker-ce
  sudo service docker start
  sudo usermod -aG docker ${USER}
}

apt_autoremove(){
  sudo apt autoremove && sudo apt clean
}

apt_install_rubymine(){
  if ! [ -x "$(command -v rubymine)" ]; then
    report_header "$ARROW Installing Rubymine "
    sudo snap install rubymine --classic
  fi
}

apt_install_datagrip(){
  if ! [ -x "$(command -v datagrip)" ]; then
    report_header "$ARROW Installing Rubymine "
    sudo snap install datagrip --classic
  fi
}

apt_install_dbeaver() {
  if ! [ -x "$(command -v dbeaver)" ]; then
    echo "Installing Dbeaver..."
    sudo add-apt-repository ppa:serge-rider/dbeaver-ce -y
    sudo apt update
    sudo apt-get install dbeaver-ce -y
  fi
}

apt_install_polybar() {
  if [ ! -s ${HOME}/polybar ]; then
    echo "Installing Polybar..."
    cd $HOME
    git clone https://github.com/jaagr/polybar.git
    cd polybar && ./build.sh
  fi
}

apt_install_i3_gaps() {
  if [ ! -s ${HOME}/.config/i3 ]; then
    echo "Installing i3 Gaps..."
    cd $HOME
    mkdir -p tmp
    cd tmp
    git clone https://github.com/Airblader/xcb-util-xrm
    cd xcb-util-xrm
    git submodule update --init
    ./autogen.sh --prefix=/usr
    make
    sudo make install

    git clone https://www.github.com/Airblader/i3 i3-gaps
    cd i3-gaps
    git checkout gaps && git pull
    autoreconf --force --install
    rm -rf build
    mkdir build
    cd build
    ../configure --prefix=/usr --sysconfdir=/etc
    make
    sudo make install
  fi
}

apt_install_nerd_fonts() {
  if [ ! -s ${HOME}/polybar ]; then
    echo "Installing Polybar..."
    cd $HOME
    git clone https://github.com/ryanoasis/nerd-fonts.git
    cd nerd-fonts && ./install.sh
  fi
}

apt_install_mdbook() {
  if ! [ -x "$(command -v mdbook)" ]; then
    echo "Installing Mdbook..."
    cargo install --git https://github.com/rust-lang-nursery/mdBook.git mdbook
  fi
}

apt_install_neovim() {
  if ! [ -x "$(command -v nvim)" ]; then
    echo "Installing Neovim..."
    sudo add-apt-repository ppa:neovim-ppa/stable -y
    sudo apt-get update -y
    sudo apt-get install neovim -y
    sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
    sudo update-alternatives --config vi
    sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
    sudo update-alternatives --config vim
    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
    sudo update-alternatives --config editor
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  fi
}

apt_install_nvm() {
  if ! [ -x "$(command -v nvm)" ]; then
    echo "Installing NVM..."
    sudo apt-get update
    sudo apt-get install build-essential libssl-dev
    curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh -o install_nvm.sh
    bash install_nvm.sh
    rm install_nvm.sh
  fi
}

apt_install_jq() {
  if ! [ -x "$(command -v jq)" ]; then
    echo "Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
  fi
}

apt_install_ansible() {
  if ! [ -x "$(command -v ansible)" ]; then
    echo "Installing Ansible..."
    sudo apt-add-repository ppa:ansible/ansible -y
    sudo apt-get update
    sudo apt install ansible
  fi
}

apt_install_youtube_dl() {
  if ! [ -x "$(command -v youtube-dl)" ]; then
    echo "Installing Youtube DL..."
    sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
    sudo chmod a+rx /usr/local/bin/youtube-dl
  fi
}

apt_install_asciinema() {
  if ! [ -x "$(command -v asciinema)" ]; then
    echo "Installing Asciinema..."
    sudo apt-get install asciinema -y
    sudo pip3 install fontTools -y
  fi
}

apt_install_scrcpy() {
  if ! [ -x "$(command -v scrcpy)" ]; then
    echo "Installing scrcpy..."
    sudo snap install scrcpy
  fi
}

installAll() {
  apt_intall_git
  apt_update_upgrade
  apt_install_cmake
  generate_ssh_key
  create_projects_folder
  apt_install_etcher
  apt_install_skype
  apt_install_terminator
  apt_install_zsh
  apt_install_powerline_fonts_theme
  apt_install_zsh_syntax_highlighting
  apt_install_zsh_autosuggestions
  apt_install_rbenv
  apt_install_ruby_build
  apt_install_ruby
  apt_install_bundler
  apt_install_nodejs
  apt_install_rails
  apt_install_docker
  apt_install_postgressql
  apt_install_rubymine
  apt_install_datagrip
  apt_install_dbeaver
  apt_install_polybar
  apt_install_i3_gaps
  apt_install_nerd_fonts
  apt_install_oracle_client
  apt_install_bat
  apt_install_mdbook
  apt_install_neovim
  apt_install_nvm
  apt_install_jq
  apt_install_ansible
  apt_install_youtube_dl
  apt_install_asciinema
  apt_install_scrcpy
  apt_autoremove
}

# Let's go!
skip_intro=0
skip_dependencies=0

parse_args "$@"

[[ $skip_intro -eq 0 ]] && show_intro
[[ $skip_dependencies -eq 0 ]] && apt_install_dev_dependencies
installAll

report_header "Checking git configuration..."
set +e
git_email=$(git config user.email)
git_name=$(git config user.name)
set -e
[[ -z $git_email ]] && echo "Ensure that you set user.email: git config -f ~/.gitconfig_user user.email 'user@host.com'"
[[ -z $git_name ]] && echo "Ensure that you set user.name: git config -f ~/.gitconfig_user user.name 'Your Name'"

# Fin
report_header "Done!"
