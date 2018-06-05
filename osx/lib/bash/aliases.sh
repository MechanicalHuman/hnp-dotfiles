#!/bin/bash

# Enable aliases to be sudo’ed
alias sudo='sudo '

alias mv='mv -i'
alias cp='cp -i'

# Directory
alias back="cd -"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# List directory contents
alias l="ls -lhpo"
alias ll="ls -lhApo"

# Always enable colored `grep` output
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Get IP addresses
alias ip-public="dig +short myip.opendns.com @resolver1.opendns.com"
alias ip-local="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1' | uniq"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Clear DNS cache
alias dns-cache="sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Reload the shell (i.e. invoke as a login shell)
alias reload='exec $SHELL -l'

# clear the screen
alias cclear="printf '\\33c\\e[3J'"

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# Common places
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias p="cd ~/Active"

# Stuff I never really use but cannot delete either because of http://xkcd.com/530/
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume 7'"
