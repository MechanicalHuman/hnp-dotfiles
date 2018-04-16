#!/bin/bash

# ───────────────────────────  Helper functions  ───────────────────────────────

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


function header(){
  local txt="🌵 $* 🌵"
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

# ──────────────────────────────  Installers  ──────────────────────────────────

function dotfiles () {
    log 'Configuring Dotfiles'

    log 'Remove .profile'
    rm -rf "$HOME/.profile"

    log 'add .inputrc'
    curl -sL https://raw.githubusercontent.com/MechanicalHuman/dev-reproducible-env/master/linux/dotfiles/.inputrc > .inputrc
    log 'add .bashrc'
    curl -sL https://raw.githubusercontent.com/MechanicalHuman/dev-reproducible-env/master/linux/dotfiles/.bashrc > .bashrc
    log 'add .bash_prompt'
    curl -sL https://raw.githubusercontent.com/MechanicalHuman/dev-reproducible-env/master/linux/dotfiles/.bash_prompt > .bash_prompt
    log 'add .bash_profile'
    curl -sL https://raw.githubusercontent.com/MechanicalHuman/dev-reproducible-env/master/linux/dotfiles/.bash_profile > .bash_profile

    log 'Source .bash_profile'
    source "$HOME/.bash_profile"
}

# ─────────────────────────────────  MAIN  ─────────────────────────────────────

header Provisioning script for Ubuntu 16

# Set as non interactive to avoid STDIN/PIPE bugs
export DEBIAN_FRONTEND=noninteractive

log info 'Updating and upgrading the apt-get packages'
sudo apt-get update -y
sudo apt-get upgrade -y

# ──────────────────────────────────  GIT  ─────────────────────────────────────

log info 'Installing Git'
log trace 'Some distros do not come with GIT preinstalled.'

if which git > /dev/null; then
    log success 'Git already installed'
else
    sudo apt-get install git -y
    log success 'Succesfully installed git'
fi

# This will save us a few headaches when we use git from scripts
log debug 'Adding github to the known_hosts'
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# ────────────────────────────  Extra packages  ────────────────────────────────

log info 'Installing Additional packages'

# build-essential - https://packages.ubuntu.com/xenial/build-essential
log debug 'Installing build-essential'
log trace 'To compile and install native addons from npm and other sources'
sudo apt-get install build-essential -y

# libcap2 - https://packages.ubuntu.com/xenial/libcap2
log debug 'Installing libcap2-bin'
log trace 'Allows binaries to bind to protected ports (<100)'
sudo apt-get install libcap2-bin -y

# jq - https://stedolan.github.io/jq/
log debug 'Installing jq'
log trace 'Command-line JSON processor'
sudo apt-get install jq -y

log success 'Succesfully installed additional packages'

# ────────────────────────────────  NODEJS  ────────────────────────────────────

# https://nodejs.org

log info 'Installing NodeJS 9.x'

# Get the package from Node source
curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
sudo apt-get install nodejs -y

log debug 'Allow node to run on port 80/443'
sudo setcap 'cap_net_bind_service=+ep' "$(which node)"

log trace 'Making sure that the NPM config folder exists'
mkdir -p "$NPM_CONFIG_PREFIX"

log success 'Succesfully installed NodeJS'

# ──────────────────────────────────  PM2  ─────────────────────────────────────

# pm2.keymetrics.io

log info 'Installing PM2'
log trace 'Production process manager'
npm install pm2 -g

log debug 'Configuring PM2'

# Create the logs folder beforehand to avoid permision conflicts
mkdir -p "$HOME/.pm2/logs"

# Getting a hold on the PM2 executable to avoid PATH issues
PM2="$NPM_CONFIG_PREFIX/bin/pm2"

log trace 'Setting up PM2 to run on boot'
sudo "$PM2" startup -u "$USER" --hp "$HOME"

# Kill the PM2 Daemon
"$PM2" kill

log trace 'Making sure the user owns the PM2 folder'
sudo chown -R "$USER:$USER" "$HOME/.pm2"

log trace 'Installing pm2-logrotate to avoid huge log files'
"$PM2" install pm2-logrotate

log success 'Succesfully installed and configured PM2'

# ─────────────────────────────  NPM PACKAGES  ─────────────────────────────────

log info 'Installing additional NPM packages'

# clalk-cli - https://github.com/chalk/chalk-cli
log debug 'Installing chalk'
log trace 'Terminal string styling done right'
npm install chalk-cli -g

# bunyan - https://github.com/trentm/node-bunyan
log debug 'Installing bunyan'
log trace 'CLI tool to filter/view JSON log files'
npm install bunyan -g

# leasot - https://github.com/pgilad/leasot
log debug 'Installing leasot'
log trace 'Parse and output TODOs and FIXMEs from comments in your files'
npm install leasot -g

# pretty - https://github.com/MechanicalHuman/dev-bunyan-pretty
log debug 'Installing pretty'
log trace 'Pretty format for Bunayn logs, like "bunyan -o short" but pretty.'
npm install @mechanicalhuman/bunyan-pretty -g

log success 'Succesfully installed additional NPM packages'

# ────────────────────────────────  Cleanup  ───────────────────────────────────



# ─────────────────────────────────  DONE  ─────────────────────────────────────

header 'Succesfully provisioned this machine'



