#!/usr/bin/env bash

# Private
_did_backup=
_copy_count=0
_link_count=0

# Constants
ARROW='>'

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


apt_install_dev_dependencies() {
  echo "Installing dependencies..."
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

  sudo apt-get update
  sudo apt-get install -y  git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs yarn
}

apt_install_woeusb() {
  if ! [ -x "$(command -v woeusb)" ]; then
    echo "Installing WhoeUSB..."
    sudo add-apt-repository ppa:nilarimogard/webupd8 -y
    sudo apt update
    sudo apt install woeusb -y
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
     sudo apt-get update
     sudo apt-get install zsh -y
     zsh --version
     whereis zsh
     sudo usermod -s /usr/bin/zsh $(whoami)
     sudo reboot
  fi
}

apt_install_powerline_fonts_theme() {
  if [ ! -s /usr/share/powerlevel9k ]; then
    sudo apt-get install powerline fonts-powerline -y
    sudo apt-get install zsh-theme-powerlevel9k -y
    echo "source /usr/share/powerlevel9k/powerlevel9k.zsh-theme" >> ~/.zshrc
  fi
}

apt_install_rbenv() {
  if ! [ -x "$(command -v rbenv)" ]; then
    echo "Installing Rbenv..."
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL

    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    exec $SHELL
  fi
}

apt_install_ruby_build() {
  if [ ! -s ${HOME}/.rbenv/plugins/ruby-build ]; then
    echo "Installing Ruby build..."
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    exec $SHELL
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
  if ! [ -x "$(command -v rbenv)" ]; then
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
}

installAll() {
  apt_intall_git
  apt_update_upgrade
  apt_install_woeusb
  apt_install_skype
  apt_install_terminator
  apt_install_rbenv
  apt_install_ruby_build
  apt_install_ruby
  apt_install_bundler
  apt_install_nodejs
  apt_install_rails
  apt_install_zsh
  apt_install_powerline_fonts_theme
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
