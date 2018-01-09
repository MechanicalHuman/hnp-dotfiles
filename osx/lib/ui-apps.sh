#!/bin/bash

if [ -f ~/.env ]; then
    # shellcheck source=/dev/null
    source ~/.env
fi

if [ -f ~/.config/dotfiles/bash/exports.sh ]; then
    # shellcheck source=/dev/null
    source ~/.config/dotfiles/bash/exports.sh
fi


# expose the env to the ui apps
# ----------------------------------------------------------------------

launchctl setenv PATH "$PATH"

# gitconfig
# ----------------------------------------------------------------------

rm -f "$HOME/.gitconfig"
cp -f "$HOME/.config/dotfiles/git/.gitconfig" "$HOME/.gitconfig"

git config --global user.name "$NAME"
git config --global user.email "$EMAIL"
