#!/bin/bash

# ~/.bashrc: executed by bash(1) for non-login shells.

#
# Enviroment
#

export PS_SYMBOL='λ'
export PS2="❯"
export PS3="[?]"
export EDITOR="nano"
export HISTIGNORE='history:ls:ls *:date:w:man *:reload'
export HISTCONTROL='ignoreboth:erasedups'
export HISTFILESIZE=10000
export HISTSIZE=${HISTFILESIZE}
export LANG='en_US.UTF-8';
export LC_ALL='en_US.UTF-8';
export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxxxxxxxxxexex
export LESS_TERMCAP_md="${yellow}";
export PROMPT_DIRTRIM=2
export LINES=128
export NPM_CONFIG_PREFIX=$HOME/.config/npm/global
export NPM_CONFIG_CACHE=$HOME/.config/npm/.cache

PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

export PATH=$(awk -F: '{for(i=1;i<=NF;i++){if(!($i in a)){a[$i];printf s$i;s=":"}}}'<<<$PATH )




#
# OPTIONS
#

shopt -s checkwinsize;
shopt -s nocaseglob;
shopt -s histappend;
shopt -s cdspell;

for option in autocd globstar; do
    shopt -s "$option" 2> /dev/null;
done;

#
# Prompt
#


if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then

    if [ -f ~/.bash_prompt ]; then
        source ~/.bash_prompt
    else
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    fi

else
     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi



#
# Alias
#

alias sudo='sudo '
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias l="ls -lhpo"
alias ll="ls -lhApo"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias logs="pm2 logs --raw | pretty"

#
# Completition
#

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
