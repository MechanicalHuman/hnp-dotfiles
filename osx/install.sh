#!/bin/bash

LIBDIR=$PWD/osx/lib
INSTALLED_HOMEBREW=0

function header(){
  local txt="🤖 $* 🤖"
  local reset='\033[0m'
  local green='\033[32m'

  function printline() {
   num=$((${#txt} + 2))
   v=$(printf "%-${num}s" "-")
   echo -e "${v// /-}"
  }

  echo -e "$green"
  printline
  echo -e "$txt"
  printline
  echo -e "$reset"
}


function log(){

  local reset='\033[0m'
  local red='\033[31m'
  local green='\033[32m'
  local yellow='\033[33m'
  local magenta='\033[35m'
  local cyan='\033[36m'
  local dim='\033[2m'

  if [ "$1" == 'error' ]; then
    shift
    echo -e "$red ✖ $*$reset"
  elif [ "$1" == 'warn' ]; then
    shift
    echo -e "$yellow ⚠ $*$reset"
  elif [ "$1" == 'info' ]; then
    shift
    echo -e "$magenta - $*$reset"
  elif [ "$1" == 'success' ]; then
    shift
    echo -e "$green ✔ $*$reset"
  elif [ "$1" == 'debug' ]; then
    shift
    echo -e "$cyan - $*$reset"
  elif [ "$1" == 'trace' ]; then
    shift
    echo -e "$dim - $*$reset"
  else
    echo -e "$*$reset"
  fi

}


function linkme(){

    local SOURCE=$1
    local DEST=$2

    if [ -f "$SOURCE" ]; then
        if [ -f "$DEST" ] && [ ! -L "$DEST" ]; then
            chalk yellow "❕ Backing up $DEST as $DEST.bck"
            mv "$DEST" "$DEST.bck"
        fi
        ln -sf "$SOURCE" "$DEST"
        log trace "${1} -> $DEST"
    else
        log error "NOT FUND: $SOURCE"
    fi
}


function generateEnv(){
  log info 'Generating Enviroment'
  if [ -f "$HOME/.env" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.env"
  fi

  if [ -z "$FULL_NAME" ]; then
    read -r -p "What's your name?" FULL_NAME
    if [ -z "$FULL_NAME" ]; then FULL_NAME="$USER"; fi
    echo "export FULL_NAME='$FULL_NAME'" >> "$HOME/.env"
  fi

  if [ -z "$EMAIL" ]; then
    read -r -p "What's your email?" EMAIL
    if [ -z "$EMAIL" ]; then EMAIL="$USER@$(hostname -s)"; fi
    echo "export EMAIL='$EMAIL'" >> "$HOME/.env"
  fi

  if [ -z "$HOMEPAGE" ]; then
    read -r -p "What's your website?" HOMEPAGE
    if [ -z "$HOMEPAGE" ]; then HOMEPAGE="http://www.example.com"; fi
    echo "export HOMEPAGE='$HOMEPAGE'" >> "$HOME/.env"
  fi

}


function install_homebrew(){
  log info "Installing: Homebrew"

  if which brew >/dev/null; then
      log debug "Homebrew is already installed"
  else
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  # Update HomeBrew
  log debug "Updating HomeBrew"
  brew update > /dev/null
  brew tap Homebrew/bundle
  brew bundle --file="$LIBDIR/packages/Brewfile"
  brew bundle dump --force --global

  log debug "Making Mongo a Home"
  mkdir -p "$HOME/Databases/mong"

  log success "Succesfully installed Homebrew"
  INSTALLED_HOMEBREW=1
}

function update_bash(){
  log info "Configuring: Bash4 as the default shell"
  if [ "$(grep -c /usr/local/bin/bash /private/etc/shells)" -eq 0 ]; then
    sudo bash -c 'echo -e /usr/local/bin/bash >> /private/etc/shells'
    log debug "Bash4 added to your shells"
  else
    log warn "usr/local/bin/bash seems to exist already in your shell options"
  fi

  sudo chsh -s '/usr/local/bin/bash' 2> /dev/null
  log success "Bash4 configured as default shell"
}

function configure_dotfiles(){
  log info "Configuring: Dotfiles"

  local DOTPATH=$HOME/.config/dotfiles
  mkdir -p "$DOTPATH/bash"
  mkdir -p "$DOTPATH/git"

  log debug "Configuring: BASH"
  linkme "$LIBDIR/ui-apps.sh" "$HOME/.ui"
  linkme "$LIBDIR/interactive.sh" "$HOME/.bash_profile"
  linkme "$LIBDIR/bashrc.sh" "$HOME/.bashrc"
  linkme "$LIBDIR/logout.sh" "$HOME/.bash_logout"

  linkme "$LIBDIR/bash/aliases.sh" "$DOTPATH/bash/aliases.sh"
  linkme "$LIBDIR/bash/completition.sh" "$DOTPATH/bash/completition.sh"
  linkme "$LIBDIR/bash/exports.sh" "$DOTPATH/bash/exports.sh"
  linkme "$LIBDIR/bash/functions.sh" "$DOTPATH/bash/functions.sh"
  linkme "$LIBDIR/bash/options.sh" "$DOTPATH/bash/options.sh"
  linkme "$LIBDIR/bash/promt.sh" "$DOTPATH/bash/promt.sh"

  log debug "Configuring: GIT"

  linkme "$LIBDIR/git/.gitconfig" "$DOTPATH/git/.gitconfig"
  linkme "$LIBDIR/git/.gitattributes" "$HOME/.gitattributes"
  linkme "$LIBDIR/git/.gitignore" "$HOME/.gitignore"

  rm -f "$HOME/.gitconfig"
  cp -f "$LIBDIR/git/.gitconfig" "$HOME/.gitconfig"
  git config --global user.name "$NAME"
  git config --global user.email "$EMAIL"

  # Extras
  log debug "Configuring: Extras"
  for dotfile in $LIBDIR/extras/.*
    do
      if [ -f "$dotfile" ]; then
          local base
          base=$(basename "$dotfile")
          linkme "$dotfile" "$HOME/$base"
      fi
  done



  # LaunchAgent
  log debug "Exposing: .env as a LaunchAgent"
  cat > "$HOME/Library/LaunchAgents/env-ui.plist" <<EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>env-ui</string>
          <key>ProgramArguments</key>
          <array>
              <string>$SHELL</string>
              <string>$HOME/.ui</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
      </dict>
      </plist>
EOF

  launchctl load "$HOME/Library/LaunchAgents/env-ui.plist" 2>/dev/null
  launchctl start env-ui 2>/dev/null

  exec $SHELL -l

  log success "Succesfully configured .dotfiles"

}

function configure_npm(){
  log info "Installing: NPM packages"
  xargs -n1 npm install -g < "$LIBDIR/packages/npm"
  log success "Succesfully installed NPM packages"
}

function configure_pm2(){
  log info "Configuring: PM2"
  # Create the logs folder beforehand to avoid permision conflicts
  mkdir -p "$HOME/.pm2/logs"

  sudo "$(which pm2)" startup launchd -u "$USER" --hp "$HOME"
  $(which pm2) install pm2-logrotate

  log success "Succesfully configured PM2"
}

function configure_osx(){
  log info "macOS nitpicking"

  # Close any open System Preferences panes, to prevent them from overriding
  # settings we’re about to change
  osascript -e 'tell application "System Preferences" to quit'

  log debug "Show the ~/Library directory"
  chflags nohidden "${HOME}/Library"

  log debug "Show the /Volumes folder"
  sudo chflags nohidden /Volumes

  log debug "Appearance: Graphite"
  defaults write -g AppleAquaColorVariant -int 6

  log debug "Set highlight color to yellow"
  defaults write NSGlobalDomain AppleHighlightColor -string "0.999120 0.872632 0.008614"

  log debug "Set sidebar icon size to small"
  defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

  log debug "Show scroll bars: WhenScrolling"
  defaults write -g AppleShowScrollBars -string "WhenScrolling"

  log debug "Enable AirDrop over Ethernet and on unsupported Macs running Lion"
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

  log debug "Correct spelling automatically"
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true

  log debug "Restore windows when quitting or re-opening apps"
  defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true
  defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool true

  log debug "Display ASCII control characters in caret notation"
  defaults write -g NSTextShowsControlCharacters -bool true

  log debug "SHow all extentions"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  log debug "disable the warning when changing a file extension"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  log debug "Avoid creating .DS_Store files on USB and Network Drives"
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

  log debug "Disable Dashboard"
  defaults write com.apple.dashboard mcx-disabled -bool true

  log debug "Only use UTF-8 in Terminal.app"
  defaults write com.apple.terminal StringEncodings -array 4

  log debug "Configuring Dock size to 36"
  defaults write com.apple.dock tilesize -int 36

  log debug "Show indicator lights for open applications in the Dock"
  defaults write com.apple.dock show-process-indicators -bool true

  log debug "Configuring LaunchPad grid [3x9]"
  defaults write com.apple.dock springboard-rows -int 3
  defaults write com.apple.dock springboard-columns -int 9
  defaults write com.apple.dock ResetLaunchPad -bool true

  log debug "Use scroll gesture with the Ctrl (^) modifier key to zoom"
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

  log debug "Disable shadow in screenshots"
  defaults write com.apple.screencapture disable-shadow -bool true

  log debug "When performing a search, search the current folder by default"
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  log debug "New window points to home"
  defaults write com.apple.finder NewWindowTarget -string "PfHm"

  log debug "show hidden files by default"
  defaults write com.apple.finder AppleShowAllFiles -bool true

  log debug "empty Trash securely by default"
  defaults write com.apple.finder EmptyTrashSecurely -bool true

  log debug "Restart automatically if the computer freezes"
  sudo systemsetup -setrestartfreeze on


  log debug "Expand save panel by default"
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  log debug "Expand print panel by default"
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  log debug "Disable the 'Are you sure you want to open this application?' dialog"
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  log debug "Check for software updates daily, not just once per week"
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

  log info "SSD DRIVE BABY"
  log debug "Disable hibernation (speeds up entering sleep mode)"
  sudo pmset -a hibernatemode 0
  log debug "Disable the sudden motion sensor as it’s not useful for SSDs"
  sudo pmset -a sms 0


  log debug "Enable subpixel font rendering on non-Apple LCDs"
  defaults write NSGlobalDomain AppleFontSmoothing -int 2

  log success "Succesfully configured MacOS"
}

function confirm() {
  log "💾  Do you want to $1?"
  select option in "Yes" "No"; do
    case $option in
        Yes )
            $2
            break
            ;;
        No )
            log warn "Skipping $1"
            break
            ;;
        *)
            log error "Please select an option (number)"
            ;;
    esac
  done
}




# ----------------------------------------------------------------------

header OSX CONFIGURATION SCRIPT

# Ask for the administrator password upfront
sudo -v
# update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

generateEnv

confirm 'Install HomeBrew' install_homebrew

if [ "$INSTALLED_HOMEBREW" -eq 1 ]; then
  confirm 'Update Bash to Bash4' update_bash
fi

confirm 'Configure .dotfiles' configure_dotfiles

confirm 'Configure MacOS' configure_osx

if which npm >/dev/null; then
  confirm 'Install NPM packages' configure_npm
  confirm 'Configure PM2' configure_pm2
fi

header Done



