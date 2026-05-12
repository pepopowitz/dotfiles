# Open main in browser
alias web='gh repo view --web'

# Open current branch in browser
alias webbranch='gh repo view --web --branch $(git symbolic-ref --quiet --short HEAD )'

# Browse pulls for current repo
alias pulls='gh pr list --web'

# git aliases
alias gco='git checkout'
# "gco quick", to skip post-checkout hook
alias gcoq='git -c core.hooksPath=/dev/null checkout'
alias gpo='git push origin'
alias gpo1='git push --set-upstream origin $(git symbolic-ref --quiet --short HEAD )'
alias gst='git status'

alias gcam='git add . && git commit -am'
alias gcam!='git add . && git commit --no-verify -am'
alias gkm='git commit -m'
alias gkm!='git commit --no-verify -m'

# Thanks, [Elijah](https://twitter.com/elijahmanor/status/1562077209321512965)!
alias branchy="branches 20 | fzf --header \"Switch to recent branch\" --pointer=\"\" | xargs git switch"
alias unstashy="stashes 100 | fzf --header \"Apply recent stash\" --pointer=\"\" | cut -d: -f1 | xargs git stash apply"

# Open PR for current branch in browser. Against `main`, unless specified in an argument.
function open-pr() {
  if [[ $1 ]] then
    gh pr create --web --base $1
  else
    gh pr create --web
  fi
}

function branch() {
  git checkout -b $1
}

function stash() {
  git add .
  if [[ $1 ]] then
    git stash push -m "$1"
  else
    git stash push
  fi
}

alias stashdiff='git stash show -p'

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

function sync() {

  local mainline=$(main_or_master)

  git checkout $mainline

  if [[ `git remote -v | grep upstream` ]]; then
    echo "syncing to upstream..."
    git pull upstream $mainline
    git push origin
  else
    echo "syncing to origin..."
    git pull origin $mainline
  fi
}

function main_or_master() {
  if (branch_exists main-js); then
    echo 'main-js'
  elif (branch_exists main); then
    echo 'main'
  else
    echo 'master'
  fi
}

function branches() {
  COUNT=${1:-5}
  git branch --sort=-committerdate | head -n $COUNT
}

function stashes() {
  COUNT=${1:-5}
  git stash list | head -n $COUNT
}

function branch_exists() {
    local branch=${1}
    local exists=$(git branch --list ${branch})

    if [[ -z ${exists} ]]; then
        return 1
    else
        return 0
    fi
}

function rebaseonmain() {
  local mainline=$(main_or_master)
  if [[ `git status --porcelain` ]]; then
    local needToStashAndUnstash=true
  else
    local needToStashAndUnstash=false
  fi

  if [[ "$needToStashAndUnstash" = true ]]
  then
    stash
  fi

  echo "syncing $mainline branch to upstream...."
  sync

  git checkout -

  echo "rebasing on $mainline...."
  git rebase $mainline

  if [[ "$needToStashAndUnstash" = true ]]
  then
    unstash
  fi
}

# Applies a prefix to gkm based on the current feature branch number.
function gkmls() {
  local branch=$(git branch --show-current)
  if [[ "$branch" == ls-* ]]; then
    local prefix=$(echo "$branch" | cut -d'-' -f1,2)
    gkm "$prefix: $1"
  else
    gkm "$1"
  fi
}

alias skips="git ls-files -v | grep '^S'"
alias skip="git update-index --skip-worktree"
alias unskip="git update-index --no-skip-worktree"
alias ughlockfile="rm -f ./package-lock.json && npm install"
alias dammitlockfile="rm -f ./package-lock.json && npm run clean:nm && npm install"
alias flipstaging="gco staging && git fetch origin staging && git reset --hard origin/staging"

# maybe temp function to identify from gh-stack what the target branch is.
function stack-base() {
	local branch
	branch=$(git branch --show-current)

	# Try clabby/st first
	local st_base
	st_base=$(st status 2>/dev/null | awk -F'|' -v b="$branch" '
		$2 ~ b { gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3); print $3 }
	')
	if [[ -n "$st_base" ]]; then
		echo "$st_base"
		return
	fi

	# Fall back to gh-stack
	local stack_file=".git/gh-stack"
	if [[ -f "$stack_file" ]]; then
		local gh_base
		gh_base=$(jq -r --arg b "$branch" '
			.stacks[] |
			(.branches | map(.branch) | index($b)) as $i |
			if $i != null then
				if $i > 0 then .branches[$i - 1].branch
				else .trunk.branch
				end
			else empty
			end
		' "$stack_file" 2>/dev/null)
		if [[ -n "$gh_base" ]]; then
			echo "$gh_base"
			return
		fi
	fi

	echo "main"
}

function ugh() {
  stash 'ugh, drop' && ("$@") && git stash pop
}
