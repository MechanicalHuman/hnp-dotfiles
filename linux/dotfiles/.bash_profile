#!/bin/bash

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

# show the PM2 Status
if which pm2 > /dev/null; then
    pm2 list
fi
