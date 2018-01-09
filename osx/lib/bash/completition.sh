#!/bin/bash

# Add tab completion for many Bash commands

if [ -f /usr/local/share/bash-completion/bash_completion ]; then
    # shellcheck disable=SC1091
    . /usr/local/share/bash-completion/bash_completion
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
if [ -e "$HOME/.ssh/config" ]; then
 complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;
fi

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter node" killall;
