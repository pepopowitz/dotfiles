function lean() {
  cd ~/sjh/dev/leanscaper/$1
}

function sjh() {
  cd ~/sjh/dev/personal/$1
}

function nova() {
  cd ~/sjh/dev/nova/$1
}

function casep() {
  cd ~/sjh/dev/nova/caseparts/$1
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

function doit() {
  $@ # executes all arguments as a command
  open raycast://confetti # sprays confetti on the screen
  say "the dishes are done man" -v Karen # announces that it's done
}

function jwt_decode(){
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$1"
}

# Find all reference links in a doc and stub them out at the end of the file.
#  Not yet smart enough to ignore links that are already defined.
function md_links() {
  # $1: a file path
  echo "adding links to $1"
  grep -o '\[[^]]*\]\[[^]]*\]' "$1" | sed 's/\(\[[^]]*\]\)\(\[[^]]*\]\)/\2:/g' >> "$1"
}

# This is a function I used to enable quick cherry-picking of a ton of commits from `main` to `unsupported/1.3`.
#   I had created the `unsupported/1.3` branch from `main`, then it sat dormant for a year and a half. 
#   This allowed me to not start over.
function pickit() {
  local sha=$1
  local mode=$2

  case $mode in
    1)
      # list only the files changed in a specific commit
      git show --name-only "$sha"
      ;;
    2)
      # cherry-pick the commit onto the current branch
      git cherry-pick "$sha"

      # remove files from the index that I've already deleted in this branch
      git rm -r --ignore-unmatch ./docs sidebars.js ./versioned_docs/version-8.{0..6}/ ./versioned_sidebars/version-8.{0..6}-sidebars.json
      git rm -r --ignore-unmatch ./optimize ./optimize_sidebars.js ./optimize_versioned_docs/version-3.{8..14}.0/ ./optimize_versioned_sidebars/version-3.{8..14}.0-sidebars.json 

      # eyeball the remaining changes
      git status
      ;;
    3)
      # commit the cherry-pick
      git cherry-pick --continue --no-edit
      ;;
    *)
      echo "Invalid mode. Please use 1, 2, or 3."
      ;;
  esac
}
