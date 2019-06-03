
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