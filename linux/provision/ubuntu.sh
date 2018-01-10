#!/bin/bash

function log () {
  echo "  ○ $@"
}


function installGit () {
    if which git > /dev/null; then
        log 'Git already installed'
    else
        log 'Installing Git'
        sudo apt-get install git -y
    fi

    log 'Adding github to the known_hosts'
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
}


function installNode () {
    log 'Installing NodeJS 8.x'
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install build-essential libcap2-bin nodejs jq -y

    log 'Allow node to run on port 80/443'
    sudo setcap 'cap_net_bind_service=+ep' `which node`

    log 'Configuring NPM'

    mkdir -p $NPM_CONFIG_PREFIX
    mkdir -p $HOME/.pm2/logs

    echo "depth=0" > $HOME/.npmrc

    npm install pm2 -g
    npm install bunyan -g
    npm install @mechanicalhuman/bunyan-pretty -g

    log 'Configuring PM2'

    sudo $NPM_CONFIG_PREFIX/bin/pm2 startup -u $USER --hp $HOME
    # Be sure the User owns the PM2 Folderls -la /root
    $NPM_CONFIG_PREFIX/bin/pm2 kill
    sudo chown -R $USER:$USER $HOME/.pm2
    $NPM_CONFIG_PREFIX/bin/pm2 install pm2-logrotate
}


function dotfiles () {

    log 'Configuring Dotfiles'

    log 'Remove .profile'
    rm -rf $HOME/.profile

    log 'add .inputrc'
    curl -sL https://raw.githubusercontent.com/MechanicalHuman/dev-reproducible-env/master/linux/dotfiles/.inputrc > .inputrc
    log 'add .bashrc'
    curl -sL https://raw.githubusercontent.com/MechanicalHuman/dev-reproducible-env/master/linux/dotfiles/.bashrc > .bashrc
    log 'add .bash_prompt'
    curl -sL https://raw.githubusercontent.com/MechanicalHuman/dev-reproducible-env/master/linux/dotfiles/.bash_prompt > .bash_prompt
    log 'add .bash_profile'
    curl -sL https://raw.githubusercontent.com/MechanicalHuman/dev-reproducible-env/master/linux/dotfiles/.bash_profile > .bash_profile

    log "Source the bashrc"
    source $HOME/.bash_profile

}


echo "---------------------------------"
echo "Provisioning script for Ubuntu 16"
echo "---------------------------------"

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -y
sudo apt-get upgrade -y

installGit

dotfiles

installNode

echo "---------------------------------"
echo "   Succesfully provisioned host  "
echo "---------------------------------"


