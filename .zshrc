# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="spaceship"
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Customize Spaceship
SPACESHIP_NODE_SHOW=false
SPACESHIP_PACKAGE_SHOW=false
SPACESHIP_ELM_SHOW=false
SPACESHIP_RUBY_SHOW=false
SPACESHIP_ELIXIR_SHOW=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  exec_time     # Execution time
  line_sep      # Line break
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
  )


# chruby
source /usr/local/share/chruby/chruby.sh
chruby 2.5.0

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Aliases
alias sudo='sudo ' # necessary for zsh to understand sudo
alias vi="nvim"
alias vim="nvim"
alias mux="tmuxinator"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gl="git log"
alias gpush="git push"
alias gpull="git pull"
# alias ack="ack-grep"
alias bespec="bundle exec rspec"
alias bi="bundle install -j 3"
alias be="bundle exec"
alias webrick="bundle exec rails s"
alias thin="bundle exec rails s thin"
alias puma="bundle exec rails s puma -b 0.0.0.0"
alias regendb="be rake db:drop; be rake db:create; be rake db:migrate; be rake db:seed;"
alias regendbtest="RAILS_ENV=test be rake db:drop;RAILS_ENV=test be rake db:create;RAILS_ENV=test be rake db:migrate;RAILS_ENV=test be rake db:seed;"
alias mdman="bundle exec middleman -b 0.0.0.0"

alias npmt="npm run -s test"
alias npml="npm run -s lint"
alias npmf="npm run flow"
alias npma="npmt && npml && npmf"

# Spacemacs
alias update-spacemacs="cd ~/.emacs.d && git pull --rebase; find ~/.emacs.d/elpa/2*/develop/org-plus-contrib* -name '*.elc' -delete"

# Projects
alias crypto-frontend="be rails s -p 9000 -b 0.0.0.0"

# Servers
alias edev="ssh edev"
alias phpdev="ssh phpdev"
alias fidordev="ssh fidordev"
alias fidordev18="ssh fidordev18"

export EDITOR=vim
export TERM="xterm-256color"
export REACT_DEBUGGER="open -g 'rndebugger://set-debugger-loc?port=19001'"

export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### asdf
. /usr/local/opt/asdf/asdf.sh
. /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash

### NVM
export NVM_DIR="/Users/dario/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use

### NVM: autoload entering a directory
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# tmuxinator autocompletion
source ~/.bin/tmuxinator.zsh

# fzf autocompletion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Add colors for the OneDark terminal theme
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

  # Set Spaceship ZSH as a prompt
  autoload -U promptinit; promptinit
  prompt spaceship
