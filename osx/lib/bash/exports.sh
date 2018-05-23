#!/bin/bash

# Editors
export VISUAL='code'
export EDITOR="nano"
export PREVIEW="/Applications/Preview.app"

# Prompts
export PS2="❯"
export PS3="[?]"

# History control
export HISTIGNORE='history:ls:ls *:date:w:man *:reload'
export HISTCONTROL='ignoredups:erasedups'

# Increase Bash history size. Allow 32³ entries; the default is 500.
export HISTSIZE='32768'
export HISTSIZE=${HISTFILESIZE}

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8';
export LC_ALL='en_US.UTF-8';

# Enable color support of ls
export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxxxxxxxxxexex

export MANPAGER='ul'


# PROMPT TRIM
export PROMPT_DIRTRIM=2

export LINES=128

# Extend PATH
PATH="/usr/local/sbin:$HOME/bin:$PATH"

# CLEAN PATH
PATH=$(awk -F: '{for(i=1;i<=NF;i++){if(!($i in a)){a[$i];printf s$i;s=":"}}}'<<<"$PATH" )
export PATH



