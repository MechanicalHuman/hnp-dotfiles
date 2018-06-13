#!/bin/bash


# Create a new directory and enter it
function mkd() {
  mkdir -p "$@" && cd "$_" || exit;
}

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
    cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')" || exit;
}


# Create a data URL from a file
function dataurl() {
  local mimeType

  mimeType=$(file -b --mime-type "$1");

  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8";
  fi

  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# [edit] with no arguments opens the current directory in Sublime Text, otherwise opens the given location
function edit() {
  if which subl >/dev/null; then
      local sublime
      sublime=$(which subl)
      if [ $# -eq 0 ]; then
        local _hasp=0
        for project in *.sublime-project; do
            if [ -f "$project" ]; then
                echo "$project"
                $sublime "$project"
                _hasp=1
            fi
        done
        if [ $_hasp -eq 0 ]; then
            $sublime .
        fi
    else
      $sublime "$@"
    fi
  fi
}

# # [edit] with no arguments opens the current directory in vsCode, otherwise opens the given location
# function edit() {
#   if which code >/dev/null; then
#     local vscode
#     vscode=$(which code)
#     if [ $# -eq 0 ]; then
#         local _hasp=0
#         for project in *.code-workspace; do
#             if [ -f "$project" ]; then
#                 echo "$project"
#                 $vscode "$project"
#                 _hasp=1
#             fi
#         done
#         if [ $_hasp -eq 0 ]; then
#             $vscode .
#         fi
#     else
#       $vscode "$@"
#     fi
#   fi
# }


# `open` with no arguments opens the current directory, otherwise opens the given location
function open () {
  if [ $# -eq 0 ]; then
    $(which open) .;
  else
    $(which open) "$@";
  fi;
}

# `tower` with no arguments opens the current directory, otherwise opens the given location
function tower () {
  if which gittower >/dev/null; then
      if [ $# -eq 0 ]; then
        gittower .
      else
        gittower "$@"
      fi
  fi
}

# kill the git history of the current branch
function git-nuke () {
  if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo $?)" -eq 0 ]; then
    local BRANCH
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    chalk red "This command will destroy all commit history on the current brancht"
    read -r -p "To continue please type the name of the branch. " USER_BRANCH
    if [[ $USER_BRANCH == "$BRANCH" ]]; then
      chalk -t "Deleting all commit history from {red.bold ${BRANCH}}"
      cd "$(git rev-parse --show-toplevel)" || exit
      git checkout --orphan newBranch
      git add -A  # Add all files and commit them
      git commit -m 'Initial commit'
      git branch -D "$BRANCH"  # Deletes the original branch
      git branch -m "$BRANCH"  # Rename the current branch to the original name
    else
      echo "Incorrect branch name."
      return 1
    fi
  else
    echo "Not in a git repo"
    return 1;
  fi
}


# Expand NPM command with helpers

function npm () {

  if [ -f ./package.json ]; then

    if [ "$1" == "explore" ]; then
      chalk dim "override: npm $* $SHELL"
      $(which npm) "$@" "$SHELL"
      return $?;
    fi

    if [ "$1" == "update" ]; then
       chalk dim "override: npm $* --save"
      $(which npm) "$@" --save
      return $?;
    fi

    if [ "$1" == "cleanup" ]; then
      chalk dim 'removing node_modules';
      rm -rf node_modules
      chalk dim 'removing package-lock.json'
      rm -rf package-lock.json
      chalk dim 'installing from package.json'
      npm install
      return $?;
    fi

  fi

  $(which npm) "$@"
}


# Expand BREW command with helpers
function brew () {

  if [ "$1" == "save" ]; then
      $(which brew) bundle dump --force --global
      return $?;
    fi

  $(which brew) "$@"
}


# Expland PM2 commands with helpers
function pm2 () {

  if [ "$1" == "logs" ]; then
    chalk dim "override: pm2 $* --raw"
    $(which pm2) "$@" --raw
    return $?;
  fi

  $(which pm2) "$@"
}

function set-project() {
  local DEST=$PWD
  if [ -z "$1" ]; then
    chalk red "You need to pass the shorcut to the project in dot notation"
    return 1;
  fi
  if [ ! -z "$2" ]; then
    DEST=$2
  fi

  if [ ! -f ~/.projects ]; then
    echo "#!/bin/bash" > ~/.projects
  fi

  echo "alias p.$1='open_project \"$DEST\"'" >> ~/.projects
  # shellcheck source=/dev/null
  source ~/.projects
  chalk green "Added p.$1 as a shorcut to $DEST"
}

function open_project(){
  cd "$1" || exit

  local _hasp=0
  if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo $?)" -eq '0' ]; then
    git status
  fi

  if [ -f ./package.json ]; then
    if [ ! -d ./node_modules ]; then
      npm install
    fi

    if [ "$( jq '.scripts | has("todos")' < ./package.json )" == "true" ]; then
      npm run 'todos' -s || true
       _hasp=1
    fi

  fi

  if [ $_hasp -eq 0 ]; then
   npx leasot './**/**' --skip-unsupported --ignore './node_modules/**/**' --exit-nicely
  fi
}



