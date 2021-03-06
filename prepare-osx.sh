#!/bin/bash

# Prepares a new macOS computer for web development. Updates to current version
# of macOS, installs basic command-line utilities without installing xcode,
# adds essential command line tools, git source code control, and key dotfiles,
# and otherwise prepares a new system for webdev apps, such as java, python
# and node, without dependencies on other install files
#   https://github.com/ChristopherA/prepare-osx-for-webdev

# Installation of java, python and node are currently commented out, uncomment
# if you need them, or for each tool `brew install *tool*`

# Execute on a new machine via:

# $ curl -L https://raw.githubusercontent.com/ChristopherA/prepare-osx-for-webdev/master/prepare-osx.sh | bash

# Originally inspired from Christopher Allen's dotfiles
#   https://github.com/ChristopherA/dotfiles/blob/master/install/allosxupdates.sh

# 2017-11-12 Confirmed working with macOS Sierra 10.13.1
# 2016-09-21 Confirmed working with macOS Sierra 10.12.0

# WARNING: Be careful about using `curl` piped `|` to `bash` or any other shell
# as it can compromise your system. Only execute if you trust the source!

# TBD: It is possible that after command line utilities are installed that
# additional updates may be required, even though previous test resulted in
# a report of no updates required. For now I'm forcing one last update. To
# do properly requires refactoring this script and how it does update checks,
# probably some form of 'until [ $found_updates -eq 0 ] do xxxx done'

# TBD: There should be some way if a restart is required to install a
# script to automatically starts this script again, until found_updates() is
# false. I've had too many false starts on this for it to be a priority.

# Script Debugger
# (This is in progress, not everything uses it yet, eventually I want the whole
# script to be quieter unless there are errors.)

SCRIPT_DEBUG=true
#SCRIPT_DEBUG=false

# Defines

BIN="/usr/local/bin"

# What kind of OS are we running?

echo -e "\nChecking System -- \c"

# If we on OSX, install OSX specific command line tools, brew, brew cask, etc.

if [[ `uname` == 'Darwin' ]]; then

  # Get OSX Version
  OSX_VERS=$(sw_vers -productVersion)
  OSX_VERS_FIRST=$(sw_vers -productVersion | awk -F "." '{print $2}')

  echo "we are installing on a Mac under OSX $OSX_VERS."

  # Make sure we are in the user's home directory
  cd ~

  # on 10.9+, we can leverage Software Update to get the latest CLI tools
  if [ "$OSX_VERS_FIRST" -ge 9 ];
  then

    # Warn the user before running this script

    warning=$(osascript -e 'tell application "System Events" to set myReply to button returned of (display dialog "This script will update your OSX system and prepare it for web development. Your administrator password will be required. Only enter the password if you trust the source of this script!" with title "Prepare OSX for Web Development" with icon caution default button 2 buttons {"Abort", "Continue"})')
    if [[ $warning = "Continue" ]]; then
      echo 'User selected "Continue" button...';
    elif [[ $warning = "Abort" ]]; then
      echo 'User selected "Abort" button, exiting script!';
      exit 1;
    else
      echo "$warning was selected, error!";
      exit 1;
    fi

    # Ask for the administrator password upfront

    while :; do # Loop until valid input is entered or Cancel is pressed.
        adminpwd=$(osascript -e 'Tell application "System Events" to display dialog "Enter '$USER'’s administrator password:" with title "Administrator Password" with hidden answer default answer ""' -e 'text returned of result' 2>/dev/null)
        if (( $? )); then echo 'User selected "Cancel" button, exiting script!'; exit 1; fi  # Abort, if user pressed Cancel.
        name=$(echo -n "$adminpwd" | sed 's/^ *//' | sed 's/ *$//')  # Trim leading and trailing whitespace.
        if [[ -z "$adminpwd" ]]; then
            # The user left the password blank.
            osascript -e 'Tell application "System Events" to display alert "You must enter a non-blank password; please try again." as warning' >/dev/null;
            # Continue loop to prompt again.
        else
            echo -e "$adminpwd\n" | sudo -S echo ""
            result=$(sudo -n uptime 2>&1|grep "load"|wc -l);
            if [[ $result = "       1" ]]; then
              echo "Admin password is correct...";
              # Valid password: exit loop and continue.
              unset adminpwd;
              break;
            else
              # The admin password is incorect.
              unset adminpwd;
              echo "The admin password was incorrect!";
              osascript -e 'Tell application "System Events" to display alert "The admin password was incorrect!" as warning' >/dev/null;
              # Continue loop to prompt again.
            fi
        fi
    done

    # Activate Mac Terminal Window

    osascript -e 'tell application "Terminal" to activate'

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

      # Tell software update to also install OSX Command Line Tools without prompt
      ## As per https://sector7g.be/posts/installing-xcode-command-line-tools-through-terminal-without-any-user-interaction

      touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

      sudo /usr/sbin/softwareupdate -ia
      wait

      /bin/rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

      # Check one last time for updates - TBD: refactor to do a test first.
      sudo /usr/sbin/softwareupdate -ia
      wait

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
    brew install bash-completion # http://bash-completion.alioth.debian.org
    brew install wget # https://www.gnu.org/software/wget/

    # Useful other bash or git related tools
    brew install git-extras # https://github.com/visionmedia/git-extras
    brew install hub # https://hub.github.com
    #brew install grc # http://korpus.juls.savba.sk/~garabik/software/grc.html
    #brew install bash-git-prompt # https://github.com/magicmonty/bash-git-prompt

    # Install web development code
    # brew install python # use built-in python for now
    # brew install node # https://nodejs.org/

    if $SCRIPT_DEBUG; then echo "...Tapping Brew Cask."; fi

    if $SCRIPT_DEBUG
      then
        brew tap caskroom/cask
      else
        brew tap caskroom/cask > /dev/null
    fi

    if $SCRIPT_DEBUG; then echo "...Brew Cask tapped."; fi

    # Development Tools
    brew cask install atom #http://atom.io
    brew cask install github # https://mac.github.com
    # brew cask install java # http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

    # Brew & Cask Cleanup

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

    echo -e "\n  Running maintenance scripts."

    # The locate and whathis databases, also used by apropos, is only generated weekly,
    # so run it after changing commands. This will happen in the background and can
    # take some time to generate the first time.

    sudo periodic daily weekly monthly

    # Install Solarized Terminal Settings

    # Use a modified version of the Solarized Dark theme by default in Terminal.app
    CURRENT_PROFILE="$(defaults read com.apple.terminal 'Default Window Settings')";
    if [ "${CURRENT_PROFILE}" != "solarized-dark" ]; then
      wget https://raw.githubusercontent.com/ChristopherA/prepare-osx-for-webdev/master/solarized-dark.terminal
    	open ~/solarized-dark.terminal;
    	sleep 5; # Wait a bit to make sure the theme is loaded
      # !!! NOTE THE FOLLOWING DIDN"T NOT WORK IN 10.10 BUT DOES IN 10.12
      defaults write com.apple.terminal 'Default Window Settings' -string "solarized-dark";
      defaults write com.apple.terminal 'Startup Window Settings' -string "solarized-dark";
      rm ~/solarized-dark.terminal;
    fi;

    if [ ! -f "~/.bash_profile" ]; then
      wget https://raw.githubusercontent.com/ChristopherA/prepare-osx-for-webdev/master/bash_profile;
      mv ./bash_profile ~/.bash_profile;
      echo "New ~/.bash_profile created.";
    fi

    if [ ! -f "~/.gitignore_global" ]; then
      wget https://raw.githubusercontent.com/ChristopherA/prepare-osx-for-webdev/master/gitignore_global;
      mv ./gitignore_global ~/.gitignore_global;
      echo "New ~/.gitignore_global created.";
    fi

    if [ ! -f "~/.bash_profile.local" ]; then
      wget https://raw.githubusercontent.com/ChristopherA/prepare-osx-for-webdev/master/bash_profile.local;
      mv ./bash_profile.local ~/.bash_profile.local;
      echo "New ~/.bash_profile.local created.";

      osascript -e 'Tell application "System Events" to display alert "Edit your .bash_profile.local with your own Git credentials…"' >/dev/null;
      atom ~/.bash_profile.local;
    fi

    sleep 5
    osascript -e 'Tell application "System Events" to activate' >/dev/null
    osascript -e 'Tell application "System Events" to display alert "Installation is complete!"' >/dev/null

 else
   echo "This script only supports OSX 10.9 Mavericks or better! Exiting..."
 fi

else
  echo "We are not running on a Mac! Install scripts for non-Macs are a work-in-progress."
fi

echo -e "\nScript finished.\n"
