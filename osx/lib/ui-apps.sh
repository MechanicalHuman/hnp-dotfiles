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
launchctl setenv NAME "$NAME"
launchctl setenv EMAIL "$EMAIL"
launchctl setenv HOMEPAGE "$HOMEPAGE"
launchctl setenv NPM_TOKEN "$NPM_TOKEN"
launchctl setenv NPM_SCOPE "$NPM_SCOPE"
launchctl setenv VISUAL "$VISUAL"
# gitconfig
# ----------------------------------------------------------------------

rm -f "$HOME/.gitconfig"
cp -f "$HOME/.config/dotfiles/git/.gitconfig" "$HOME/.gitconfig"

git config --global user.name "$NAME"
git config --global user.email "$EMAIL"


cat > "$HOME/Library/Application Support/com.fournova.Tower2/environment.plist" <<EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>PATH</key>
        <string>"$PATH"</string>
        <key>NAME</key>
        <string>"$NAME"</string>
        <key>EMAIL</key>
        <string>"$EMAIL"</string>
        <key>HOMEPAGE</key>
        <string>"$HOMEPAGE"</string>
        <key>NPM_TOKEN</key>
        <string>"$NPM_TOKEN"</string>
        <key>NPM_SCOPE</key>
        <string>"$NPM_SCOPE"</string>
        <key>VISUAL</key>
        <string>"$VISUAL"</string>
      </dict>
    </plist>
EOF
