#!/bin/bash

if [ -f ~/.env ]; then
  # shellcheck source=/dev/null
  source ~/.env
fi

if [ -f ~/.config/dotfiles/bash/options.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/options.sh
fi

if [ -f ~/.config/dotfiles/bash/exports.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/exports.sh
fi

if [ -f ~/.config/dotfiles/bash/functions.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/functions.sh
fi

if [ -f ~/.config/dotfiles/bash/aliases.sh ]; then
  # shellcheck source=/dev/null
  source ~/.config/dotfiles/bash/aliases.sh
fi

