#!/bin/bash

# Add tab completion for many Bash commands

if [ -f /usr/local/share/bash-completion/bash_completion ]; then
    # shellcheck disable=SC1091
    . /usr/local/share/bash-completion/bash_completion
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
if [ -e "$HOME/.ssh/config" ]; then
  cc_names=""
  cc_names+=$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')
  if [ -e "$HOME/.ssh/config.d/" ]; then
    for conf in ~/.ssh/config.d/*
      do
        if [ -f "$conf" ]; then
            cc_names+="$cc_names $(grep "^Host" "$conf" | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')"
        fi
    done
  fi
  complete -o "default" -o "nospace" -W "$cc_names" scp sftp ssh;
  unset cc_names
fi

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter node" killall;

complete -o "nospace" -W "--no-time-stamps --stamp-format --time-zone --level --depth --max-array-length --strict" pretty;
