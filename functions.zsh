
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

function gdc() {
  git-duet commit -m $1
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