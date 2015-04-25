#!/bin/bash

# Originally from Christopher Allen's dotfiles
#   https://github.com/ChristopherA/dotfiles/blob/master/install/allosxupdates.sh

# Modified to only install basic command-line utilities and webdev files,
# such as python and node, without dependencies on other install files
#   https://github.com/ChristopherA/prepare-osx-for-webdev

# Execute on a new machine via:

# $ curl -L https://raw.githubusercontent.com/ChristopherA/prepare-osx-for-webdev/master/prepare-osx-for-webdev.sh | bash

# WARNING: Be careful about using `curl` piped `|` to bash or any other shell
# as it can compromise your system. Only execute if you trust the source!

# Script Debugger
# (This is in progress, not everything uses it yet, eventually I want the whole
# script to be quieter unless there are errors.)

SCRIPT_DEBUG=true
#SCRIPT_DEBUG=false

# Defines

BIN="/usr/local/bin"

# Ask for the administrator password upfront
echo -e "\nUpdating OSX system software and developer tools.\nYour administrator password will be required. \nOnly enter password if you trust the source of this script!"
sudo -v

# What kind of OS are we running?

echo -e "\nChecking System -- \c"

# If we on OSX, install OSX specific command line tools, brew, brew cask, etc.

if [[ `uname` == 'Darwin' ]]; then

  # Get OSX Version
  OSX_VERS=$(sw_vers -productVersion)
  OSX_VERS_FIRST=$(sw_vers -productVersion | awk -F "." '{print $2}')

  echo "we are installing on a Mac under OSX $OSX_VERS."

  # on 10.9+, we can leverage Software Update to get the latest CLI tools
  if [ "$OSX_VERS_FIRST" -ge 9 ];
  then

    # Define some variables...
    tmp_file=".softwareupdate.$$"
    reboot=""
    found_updates=""

    echo -e "\n  Checking Apple Software Update Server for available updates,\n  Please be patient. This process may take a while to complete... \c"
    sudo /usr/sbin/softwareupdate -l &> $tmp_file
    wait

    echo -e "\n"
    reboot=$(/usr/bin/grep "restart" $tmp_file | /usr/bin/wc -l | xargs )
    echo "    $reboot updates require a reboot."
    /usr/bin/grep "restart" $tmp_file

    echo ""
    found_updates=$(/usr/bin/grep -v "restart" $tmp_file | grep "recommended" | /usr/bin/wc -l | xargs )
    echo "    $found_updates updates do not require a reboot."
    /usr/bin/grep -v "restart" $tmp_file | grep "recommended"
    echo ""

    if [ $found_updates = "0" ]
      then
         echo "    No new recommended updates found."
      else
        if [ $reboot = "0" ]
        then
          echo "    Updates found, but no reboot required. Installing now."
          echo -e "    Please be patient. This process may take a while to complete.\n"
          sudo /usr/sbin/softwareupdate -ia
          wait
          echo -e "\n  Finished with all Apple Software Update installations."
        else
          echo "    Updates found, reboot required. Installing now."
          echo "    Please be patient. This process may take a while to complete."
          echo -e "    Once complete, this machine will automatically restart.\n"
          sudo /usr/sbin/softwareupdate -ia
          wait
          echo -e "    Finished with all Apple Software Update installations."
        fi
      fi

    # cleaning up temp files before possible reboot
    /bin/rm -rf $tmp_file

    if [ $reboot != "0" ]
    then
      echo -e "\n  Apple Software Updates requiring restart have been installed."
      echo -e "  Please run this script again after restart.\n"
      read -p "Press any key to restart..." </dev/tty
      wait
      echo -e "\nRestarting..."
      sudo /sbin/shutdown -r now
    fi

    echo -e "\n  Checking to see if Apple Command Line Tools are installed."
    xcode-select -p &>/dev/null
    if [[ $? -ne 0 ]]
    then
      echo "    Apple Command Line Utilities not installed. Installing..."
      echo "    Please be patient. This process may take a while to complete."

      # Tell software update to also install OXS Command Line Tools without prompt
      ## As per https://sector7g.be/posts/installing-xcode-command-line-tools-through-terminal-without-any-user-interaction

      touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

      sudo /usr/sbin/softwareupdate -ia
      wait

      /bin/rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
      echo -e "\n    Finished installing Apple Command Line Tools."
    else
      echo -e "\n    Apple Command Line Tools already installed."
    fi

    # Create local applications folder

    echo -e "\n    Creating ~/Applications if it doesn't exist"

    if [ ! -d ~/Applications ]; then mkdir ~/Applications; fi

    # Install Homebrew http://brew.sh if exits, force via curl if necessary

      # Check for Homebrew
      if test ! $(which brew); then
        if $SCRIPT_DEBUG; then echo "...Installing Homebrew."; fi

        if $SCRIPT_DEBUG
          then
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
          else
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /dev/null
        fi

        # Check Homebrew installation

        if $SCRIPT_DEBUG; then echo "...Checking installation."; fi

        if $SCRIPT_DEBUG
          then
            brew doctor
          else
            brew doctor > /dev/null
        fi

        if $SCRIPT_DEBUG; then echo "...Homebrew installed."; fi

      fi

      # Update the latest version of Homebrew

      if $SCRIPT_DEBUG; then echo "...Updating Homebrew."; fi

      if $SCRIPT_DEBUG
        then
          brew update
        else
          brew update > /dev/null
      fi

      # Upgrade any outdated, unpinned brews

      if $SCRIPT_DEBUG; then echo "...Upgrade any outdated, unpinned brews."; fi

      if $SCRIPT_DEBUG
        then
          brew upgrade
        else
          brew upgrade > /dev/null
      fi

      # Symlink any .app-style brews applications locally to ~/Applications

      if $SCRIPT_DEBUG; then echo "...Symlink any .app-style brews."; fi

      if $SCRIPT_DEBUG
        then
          brew linkapps --local
        else
          brew linkapps --local > /dev/null
      fi


      # Cleanup old Homebrew formula

      if $SCRIPT_DEBUG; then echo "...Cleanup old brew formula."; fi

      if $SCRIPT_DEBUG
        then
          brew cleanup
        else
          brew cleanup > /dev/null
      fi

      # Prune dead Homebrew symlinks

      if $SCRIPT_DEBUG; then echo "...Prune dead symlinks."; fi

      if $SCRIPT_DEBUG
        then
          brew prune
        else
          brew prune > /dev/null
      fi

      if $SCRIPT_DEBUG; then echo "...Homebrew updated."; fi

    # Important early Brew installs
    brew install git # http://git-scm.com
    brew install git-extras # https://github.com/visionmedia/git-extras
    brew install hub # https://hub.github.com
    brew install bash-completion # http://bash-completion.alioth.debian.org
    brew install bash-git-prompt # https://github.com/magicmonty/bash-git-prompt
    brew install grc # http://korpus.juls.savba.sk/~garabik/software/grc.html
    brew install wget # https://www.gnu.org/software/wget/

    # Install web development code
    # brew install python # use built-in python for now
    brew install node

    if $SCRIPT_DEBUG; then echo "...Installing Cask."; fi

    # Check for Cask instalation

    if $SCRIPT_DEBUG; then echo -e "...Checking if Brew Cask is installed."; fi

    if ! brew cask &> /dev/null
      then
        if $SCRIPT_DEBUG
          then
            echo "...Cask not installed. Installing."
            brew install caskroom/cask/brew-cask # http://caskroom.io
          else
            brew install caskroom/cask/brew-cask > /dev/null
        fi

        if $SCRIPT_DEBUG; then echo -e "...Finished installing Cask."; fi

      else
        if $SCRIPT_DEBUG; then echo -e "Cask already installed."; fi

    fi

    if $SCRIPT_DEBUG; then echo "...Cask installed."; fi

    # Development Tools
    brew cask install atom #http://atom.io
    brew cask install github # https://mac.github.com
    # brew cask install java # http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

    # Brew & Cask Cleanup

      # Symlink any .app-style brews applications locally to ~/Applications

      if $SCRIPT_DEBUG; then echo "...Symlink any .app-style brews."; fi

      if $SCRIPT_DEBUG
        then
          brew linkapps --local
        else
          brew linkapps --local > /dev/null
      fi


      # Cleanup old Homebrew formula

      if $SCRIPT_DEBUG; then echo "...Cleanup old brew formula."; fi

      if $SCRIPT_DEBUG
        then
          brew cleanup
        else
          brew cleanup > /dev/null
      fi

      # Prune dead Homebrew symlinks

      if $SCRIPT_DEBUG; then echo "...Prune dead symlinks."; fi

      if $SCRIPT_DEBUG
        then
          brew prune
        else
          brew prune > /dev/null
      fi

      # Cask cleanup
      if $SCRIPT_DEBUG; then echo "...Cleanup Cask caches."; fi

      if $SCRIPT_DEBUG
        then
          brew cask cleanup
        else
          brew cask cleanup > /dev/null
      fi

    # Run maintenance scripts
    # The whathis database, used by whatis and apropos, is only generated weekly,
    # so run it after changing commands.

    sudo periodic daily weekly monthly

    # Update the locate database. This will happen in the background and can
    # take some time to generate the first time.

    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

    # Repair disk permissions
    sudo diskutil repairPermissions /

    # Install Solarized Terminal Settings

    # Use a modified version of the Solarized Dark theme by default in Terminal.app
    TERM_PROFILE='Solarized-Dark';
    CURRENT_PROFILE="$(defaults read com.apple.terminal 'Default Window Settings')";
    if [ "${CURRENT_PROFILE}" != "${TERM_PROFILE}" ]; then
      wget https://raw.githubusercontent.com/ChristopherA/prepare-osx-for-webdev/master/${TERM_PROFILE}.terminal
    	open "${HOME}/${TERM_PROFILE}.terminal";
    	sleep 1; # Wait a bit to make sure the theme is loaded
    	defaults write com.apple.terminal 'Default Window Settings' -string "${TERM_PROFILE}";
    	defaults write com.apple.terminal 'Startup Window Settings' -string "${TERM_PROFILE}";
    fi;

 else
   echo "This script only supports OSX 10.9 Mavericks or better! Exiting..."
 fi

else
  echo "We are not running on a Mac! Install scripts for non-Macs are a work-in-progress."
fi

echo -e "\nFinished installation.\n"
