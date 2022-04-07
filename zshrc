export PATH=/usr/local/opt/python/libexec/bin:/usr/local/bin:~/bin:$PATH

# history setup
setopt SHARE_HISTORY
SAVEHIST=10000
HISTSIZE=9999
setopt HIST_EXPIRE_DUPS_FIRST

# AUTOCOMPLETION
## initialize autocompletion
autoload -U compinit && compinit
eval "$(starship init zsh)"
## autocompletion using arrow keys (based on history)
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

# turn off annoying bell sound (actually a blip)
unsetopt BEEP

# aliases
source ~/.aliases.zsh
source ~/.functions.zsh
source ~/.git.zsh

# eventually I'll want this
# source ~/.private.zshrc

# This won't do anything because I'm not using oh-my-zsh
#   But maybe I'll want to figure out how to do something similar with just zsh?
#   Leaving it here as a reminder when I run into the terminal title making me mad.
# ZSH_THEME_TERM_TITLE_IDLE="%~"

. /usr/local/opt/asdf/libexec/asdf.sh
