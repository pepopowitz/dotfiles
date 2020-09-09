
alias pgstart="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start"

alias pgstop="pg_ctl -D /usr/local/var/postgres stop -s -m fast && echo 'postgres server stopped'"

alias lsg="echo 'npm ls -g --depth=0\n' && npm ls -g --depth=0"

alias syncup="git syncup"
alias sync="git sync"

# alias pr="open `git config remote.origin.url`/compare/$(git rev-parse --abbrev-ref HEAD)"

gh(){
  open $(git config remote.origin.url | sed "s/git@\(.*\):\(.*\).git/https:\/\/\1\/\2/")/$1$2
}

# Open master in browser
alias web='gh'

# Open current branch in browser
alias webbranch='gh tree/$(git symbolic-ref --quiet --short HEAD )'

# Open PR for current branch in browser
alias pr='gh compare/$(git symbolic-ref --quiet --short HEAD )'

# git aliases
alias gpo='git push origin'

alias gpo1='git push --set-upstream origin $(git symbolic-ref --quiet --short HEAD )'

alias gcam='git add . && git commit -am'

# jrnl aliases
#alias today='jrnl -from today --export json | jq .entries[].title -r | awk '"'"'{print "- "$0""}'"'"' '
alias today='jrnl -from today --export json | jq '"'"'.entries[] | "- \(.title) \(.body)" | rtrimstr("\n") | rtrimstr("\n")'"'"' -r '

alias today-slack='today | pbcopy'

alias yesterday='jrnl -from yesterday -to yesterday --export json | jq '"'"'.entries[] | "- \(.title) \(.body)" | rtrimstr("\n") | rtrimstr("\n")'"'"' -r '

alias edit-jrnl='code ~/journal.txt'

alias stashes="git stash list | head -n 5" 

# hokusai consoles

alias console-staging="hokusai staging run \"bundle exec rails console\" --tty"
alias console-prod="hokusai production run \"bundle exec rails console\" --tty"

alias use-xcode-10="sudo xcode-select -s /Applications/XCode10/XCode.app"
alias use-xcode-11="sudo xcode-select -s /Applications/XCode11/XCode.app"

# more memorable name for osx plugin commands
alias finder="ofd"
alias finder-cd="cdf"

# bundle aliases
alias bx="bundle exec"
alias bxr="bundle exec rspec"

# brew aliases
alias bsl="brew services list"
alias bs="brew services"