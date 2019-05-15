export ZSH="/home/jcottobboni/.oh-my-zsh"
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
eval "$(rbenv init -)"
PATH=$PATH:/opt/oracle/instantclient_12_1
SQLPATH=/opt/oracle/instantclient_12_1
TNS_ADMIN=/opt/oracle/instantclient_12_1
LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1
ORACLE_HOME=/opt/oracle/instantclient_12_1
PATH=/opt/metasploit/ruby/bin:$PATH

source $ZSH/oh-my-zsh.sh

POWERLEVEL9K_MODE='nerdfont-complete'
source ~/.oh-my-zsh/custom/themes/powerlevel9k/powerlevel9k.zsh-theme
# Aliases.
source ~/.aliases
test -f ~/dotfiles/private/files/.aliases && source ~/dotfiles/private/files/.aliases

ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)
POWERLEVEL9K_CUSTOM_RUBY="echo -n '\ue21e' Ruby"
POWERLEVEL9K_CUSTOM_RUBY_FOREGROUND="black"
POWERLEVEL9K_CUSTOM_RUBY_BACKGROUND="red"
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="▶ "
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_CUSTOM_MEDIUM="echo -n '\uF859'"
POWERLEVEL9K_CUSTOM_MEDIUM_FOREGROUND="black"
POWERLEVEL9K_CUSTOM_MEDIUM_BACKGROUND="white"
plugins=(git ruby capistrano bundler heroku rake command-not-found python pip github gnu-utils history-substring-search )

export NVM_DIR="/home/jcottobboni/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
