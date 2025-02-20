export PATH=/opt/homebrew/bin:/usr/local/opt/python/libexec/bin:/usr/local/bin:~/bin:$PATH

# history setup
setopt SHARE_HISTORY
SAVEHIST=10000
HISTSIZE=9999
setopt HIST_EXPIRE_DUPS_FIRST

# AUTOCOMPLETION
## initialize autocompletion
autoload -U compinit && compinit
eval "$(starship init zsh)"
## See https://github.com/zsh-users/zsh-history-substring-search for docs
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

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

eval "$(mise activate zsh)"

# envswitch, for swapping between different .env files
#   thx https://github.com/sitepoint/envswitch!
eval "$(envswitch -i)"

# Set up fzf key bindings and fuzzy completion
#  ctrl-R: search history
#  ctrl-T: search files
source <(fzf --zsh)
