
function artsy() {
  cd ~/_sjh/dev/artsy/$1
}

function talks() {
  cd ~/_sjh/dev/personal/talks/$1
}

function sjh() {
  cd ~/_sjh/dev/personal/$1
}

function findport() {
  lsof -t -i :$1
}

function killport() {
  kill $(lsof -t -i :$1)
}

function pulls() {
  if [[ $1 ]] then
    (artsy $1; hub browse -- pulls)
  else
    hub browse -- pulls
  fi
}

function branch() {
  git checkout -b $1
}

function gkm() {
  git commit -m $1
}

function stash() {
  git add .
  if [[ $1 ]] then
    git stash push -m "$1"
  else
    git stash push
  fi
}

function unstash() {
  re='^[0-9]+$'
  if [[ $1 ]] then
    if [[ $1 =~ $re ]] then
      echo "Applying stash@{$1}..."
      git stash apply stash@{$1}
    else
      echo "Applying stash named "$1"..."
      git stash apply $(git stash list | grep "$1" | cut -d: -f1)
    fi
  else
    echo "Applying most recent stash..."
    git stash apply
  fi
}

function mkd () {
    mkdir -p "$1"
    cd "$1"
}

function rebaseonmaster() {
  if [[ `git status --porcelain` ]]; then
    local needToStashAndUnstash=true
  else
    local needToStashAndUnstash=false
  fi

  if [[ "$needToStashAndUnstash" = true ]]
  then
    stash
  fi

  echo "syncing master branch to upstream...."
  syncup

  git checkout -

  echo "rebasing on master...."
  git rebase master

  if [[ "$needToStashAndUnstash" = true ]]
  then
    unstash
  fi
}

function branches() {
  COUNT=${1:-5}
  git branch --sort=-committerdate | head -n $COUNT
}