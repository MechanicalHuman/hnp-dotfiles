#!/bin/bash

if [ -f ~/.bashrc ]; then
  # shellcheck source=/dev/null
  source ~/.bashrc
fi

if [ -f ~/.projects ]; then
  # shellcheck source=/dev/null
  source ~/.projects
fi

if [ -f ~/.config/dotfiles/bash/promt.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/promt.sh
fi

if [ -f ~/.config/dotfiles/bash/completition.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/completition.sh
fi

