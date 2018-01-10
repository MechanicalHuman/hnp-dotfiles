#!/bin/bash

if [ ! -n "$SSH_TTY" ]; then
  if [ "$SHLVL" -eq 1 ]; then
    printf '\33c\e[3J'
  fi
fi
