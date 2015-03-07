#!/bin/bash

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
PATH=$PATH:$HOME/.rvm/bin

if [ "$1" != "" ]; then
  ruby main.rb "$1"
else
  ruby main.rb
fi
