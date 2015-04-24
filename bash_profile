#!/bin/bash

# ~/.bash_profile: executed by the bash command interpreter for login shells.

# Put all 'bash' interface specific functionality here, such as theme,
# colors & prompt. ~/.bash_profile is not executed by non-login shells, so
# don't put anything here that bash scripts may need--they should be placed
# ~/.bashrc instead. Any non-bash specific items such as enviroment settings
# and paths should be put in ~/.profile where they are executed by all shells.

# Script Debugger

#SCRIPT_DEBUG=true
#SCRIPT_DEBUG=false

# Define Mac bash command line colors, compatible with Solarized color
# themes from http://ethanschoonover.com/solarized
export CLICOLOR=1

### Solarized-dark 'ls' colors if we are using Mac OSX `ls`
### as per https://github.com/seebi/dircolors-solarized/issues/10
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

### Colors for Light Terminal Themes
### as per http://antesarkkinen.com/blog/add-colors-to-os-x-terminal-including-ls-and-nano/
# export LSCOLORS=ExFxBxDxCxegedabagacad

## ll
alias ll='ls -FGal'

## grep colors to highlight matches
export GREP_OPTIONS='--color=auto'

## Git Colors
git config --global color.ui true
git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto

# If Generic Colourizer (GRC) is installed (`brew install grc`)
# http://korpus.juls.savba.sk/~garabik/software/grc.html
# add colors for make, gcc,g++, as, gas, ld, netstat, ping, traceroute, etc.

if [ -f $(brew --prefix)/etc/grc.bashrc ]; then
  . $(brew --prefix)/etc/grc.bashrc
fi

# from `brew install bash-completion` # http://bash-completion.alioth.debian.org

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# from `brew install bash-git-prompt` # https://github.com/magicmonty/bash-git-prompt

if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
  GIT_PROMPT_THEME=Solarized
  source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

# Set global gitignore

if [ -f ~/.gitignore_global ]; then
  git config --global core.excludesfile ~/.gitignore_global
fi

# from `brew install hub` # https://hub.github.com

alias git=hub

# All bash interface specific functionality has been executed

if $SCRIPT_DEBUG; then echo "~/.bash_profile executed."; fi

# Source any local and private settings that should not be under version
# control (for instance user credentials). ~/.bash_profile.local should be
# added to ~/.gitignore

if [ -f ~/.bash_profile.local ]; then source ~/.bash_profile.local; fi

# Because of this file's existence, neither ~/.bash_login nor ~/.profile
# will be automatically sourced unless they are sourced by the shell code.
# Here we source ~/.bashrc which will then source ~/.profile.

if [ -f ~/.bashrc ]; then source ~/.bashrc; fi
