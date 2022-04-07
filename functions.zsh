function camunda() {
  cd ~/sjh/dev/camunda/$1
}

function sjh() {
  cd ~/sjh/dev/personal/$1
}

function mkd () {
    mkdir -p "$1"
    cd "$1"
}

function findport() {
  lsof -t -i :$1
}

function killport() {
  kill $(lsof -t -i :$1)
}

# ---

# borrowed from macos oh-my-zsh plugin

# pfd: gets the path from Finder
#  https://github.com/ohmyzsh/ohmyzsh/blob/b3999a4b156185b617a5608317497399f88dc8fe/plugins/macos/macos.plugin.zsh#L178
function pfd() {
  osascript 2>/dev/null <<EOF
    tell application "Finder"
      return POSIX path of (insertion location as alias)
    end tell
EOF
}

# cd-finder: cd to the path from Finder
#  named cdf in oh-my-zsh/macos plugin
#  https://github.com/ohmyzsh/ohmyzsh/blob/b3999a4b156185b617a5608317497399f88dc8fe/plugins/macos/macos.plugin.zsh#L199
function cd-finder() {
  cd "$(pfd)"
}

# hey steve you also used to use a function named ofd from oh-my-zsh/macos, it opened finder in the current directory.
#   you don't need that anymore, just use `open _path_`. 
