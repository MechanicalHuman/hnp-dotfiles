#!/bin/bash

function prompt() {

    local EXIT="$?"

    local PS_SYMBOL='λ'

    local reset='\[\e[0m\]'
    local bold='\[\e[1m\]'
    local dim='\[\e[2m\]'
    local red='\[\e[31m\]'
    local green='\[\e[32m\]'
    local yellow='\[\e[33m\]'
    local cyan='\[\e[36m\]'
    local white='\[\e[37m\]'

    local tabstyle='\[\033]0;\w\007'
    local userStyle="$yellow"
    local hostStyle="$green"
    local exitColor="$green"
    local workingDir='\w'

    if [ ! "$SHLVL" -eq 1 ]; then
      PS_SYMBOL='❯'
    fi

    # Highlight the hostname when connected via SSH.
    if [ -n "$SSH_TTY" ]; then
      hostStyle="$bold$green"
    fi

    # Highlight the user name when logged in as root.
    if [ "$EUID" -eq 0 ]; then userStyle="$bold$red"; fi

    # Set the lambda as red if last comand exited with non 0
    if [ $EXIT != 0 ]; then exitColor="$red"; fi


    # If a package.json on the WD, use the package name as the WD
    if [ -f ./package.json ]; then
        workingDir=$( jq '.name' < ./package.json | sed -e 's/\"//g' )
    fi



    prompt_git() {
        branchName=""

        get_git_branch() {
          git symbolic-ref --quiet --short HEAD 2> /dev/null || git rev-parse --short HEAD 2> /dev/null || echo '(unknown)'
        }

        is_branch1_behind_branch2 () {
            # Find the first log (if any) that is in branch1 but not branch2
            first_log="$(git log $1..$2 -1 2> /dev/null)"

            # Exit with 0 if there is a first log, 1 if there is not
            [[ -n "$first_log" ]]
        }

        branch_exists () {
            # List remote branches           | # Find our branch and exit with 0 or 1 if found/not found
            git branch --remote 2> /dev/null | grep --quiet "$1"
        }

        parse_git_ahead () {
            # Grab the local and remote branch
            branch="$(get_git_branch)"
            remote="$(git config --get "branch.${branch}.remote" || echo -n "origin")"
            remote_branch="$remote/$branch"

            # If the remote branch is behind the local branch        || or it has not been merged into origin (remote branch doesn't exist)
            if (is_branch1_behind_branch2 "$remote_branch" "$branch" || ! branch_exists "$remote_branch"); then
                echo 1
            fi
        }

        parse_git_behind () {
            # Grab the branch
            branch="$(get_git_branch)"
            remote="$(git config --get "branch.${branch}.remote" || echo -n "origin")"
            remote_branch="$remote/$branch"
            # If the local branch is behind the remote branch
            if is_branch1_behind_branch2 "$branch" "$remote_branch"; then
                echo 1
            fi
        }

        parse_git_dirty() {
            # If the git status has *any* changes (e.g. dirty), echo our character
            if [[ -n "$(git status --porcelain 2> /dev/null)" ]]; then
                echo 1
            fi
        }


        get_git_status() {

            output="$bold"

            if [[ "$dirty_branch" == 1 ]]; then
                synced_symbol="● $branchName"
                unpushed_symbol="▲ $branchName"
                unpulled_symbol="▼ $branchName"
                unpushed_unpulled_symbol="⬢ $branchName"
            else
                synced_symbol="◎ $branchName"
                unpushed_symbol="△ $branchName"
                unpulled_symbol="▽ $branchName"
                unpushed_unpulled_symbol="⬡ $branchName"
            fi;

            if [[ "$branch_ahead" == 1 && "$branch_behind" == 1 ]]; then
                output+="$red$unpushed_unpulled_symbol"
            elif [[ "$branch_behind" == 1 ]]; then
                output+="$yellow$unpulled_symbol"
            elif [[ "$branch_ahead" == 1 ]]; then
                output+="$cyan$unpushed_symbol"
            else
                output+="$green$synced_symbol"
            fi

            echo -e "$reset$output$reset"
        }

        # Check if the current directory is in a Git repository.
        if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}")" == '0' ]; then

            branchName="$(get_git_branch)"

            # check if the current directory is in .git before running git checks
            if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then
                # Ensure the index is up to date.
                git update-index --really-refresh -q &>/dev/null;

                dirty_branch="$(parse_git_dirty)"
                branch_ahead="$(parse_git_ahead)"
                branch_behind="$(parse_git_behind)"

                echo -e " $(get_git_status)";
            else
                echo -e " $reset$branchName$reset";
            fi;

        else
            return;
        fi;
    }

   update_terminal_cwd() {
    # Identify the directory using a "file:" scheme URL, including
    # the host name to disambiguate local vs. remote paths.

    # Percent-encode the pathname.
    local url_path=''
    {
        # Use LC_CTYPE=C to process text byte-by-byte. Ensure that
        # LC_ALL isn't set, so it doesn't interfere.
        local i ch hexch LC_CTYPE=C LC_ALL=
        for ((i = 0; i < ${#PWD}; ++i)); do
      ch="${PWD:i:1}"
      if [[ "$ch" =~ [/._~A-Za-z0-9-] ]]; then
          url_path+="$ch"
      else
          printf -v hexch "%02X" "'$ch"
          # printf treats values greater than 127 as
          # negative and pads with "FF", so truncate.
          url_path+="%${hexch: -2:2}"
      fi
        done
    }

    printf '\e]7;%s\a' "file://$HOSTNAME$url_path"
  }


    PS1="$tabstyle";


    PS1+="$reset$userStyle\\u"
    PS1+="$reset$dim$white:"
    PS1+="$reset$hostStyle\\h";

    PS1+="$reset$dim$white in "
    PS1+="$reset$white$workingDir";

    PS1+="$(prompt_git)"; # Git repository details

    PS1+="$reset"


    PS1="$PS1\\n$exitColor$PS_SYMBOL$reset "

    if [ "$TERM_PROGRAM" == "Apple_Terminal" ]; then
      update_terminal_cwd
    fi

    # Update bash_history
    history -a
    history -c
    history -r

    export PS1;
}

export PROMPT_COMMAND=prompt
