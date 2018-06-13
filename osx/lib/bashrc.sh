#!/bin/bash

if [ -f ~/.env ]; then
  # shellcheck source=/dev/null
  source ~/.env
fi

if [ -f ~/.config/dotfiles/bash/exports.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/exports.sh
fi

if [ -f ~/.config/dotfiles/bash/options.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/options.sh
fi

if [ -f ~/.config/dotfiles/bash/functions.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/functions.sh
fi

if [ -f ~/.config/dotfiles/bash/aliases.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/aliases.sh
fi

# Test for an interactive shell. There is no need to set anything past this
# point for scp and rcp, and it is important to refrain from outputting anything
# in those cases.

if [[ $- != *i* ]] ; then
    # Shell is non-interactive. Be done now
    return
fi

if [ -f ~/.config/dotfiles/bash/promt.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/promt.sh
fi

if [ -f ~/.config/dotfiles/bash/completition.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/completition.sh
fi

