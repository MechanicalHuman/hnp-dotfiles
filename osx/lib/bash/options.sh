#!/bin/bash

# Check the window size after each command and, if necessary, update the values
shopt -s checkwinsize

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# * Recursive globbing, e.g. `echo **/*.txt`
shopt -s globstar 2> /dev/null;

shopt -s autocd 2> /dev/null;
