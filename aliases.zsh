# leaving these here in case I need them later
# alias pgstart="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start"
# alias pgstop="pg_ctl -D /usr/local/var/postgres stop -s -m fast && echo 'postgres server stopped'"

alias lsg="echo 'npm ls -g --depth=0\n' && npm ls -g --depth=0"

# colorize `ls` output
alias ls='ls -G'
# brew aliases
alias bsl="brew services list"
alias bs="brew services"

# calendar magic
alias upcoming="cal -A 2"
alias past="cal -B 2"

# technology is disappointing
alias flip-audio-table="sudo killall coreaudiod && sudo launchctl stop com.apple.bluetoothd && sudo launchctl start com.apple.bluetoothd"

alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"