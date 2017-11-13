
Prepare OSX for WebDev (macOS Sierra 10.12)
======================

Script to prepare macOS Sierra 10.12 with basic command-line tools and for web development:

> https://github.com/ChristopherA/prepare-osx-for-webdev

This script largely uses [Homebrew](http://home.sh) to install web development tools and frameworks. Homebrew makes installation and updates of tools very easy: it compiles versions from current sources, it has the advantage of automatically resolving external dependencies on other tools, and you can later remove packages and items that Homebrew has installed without compromising the integrity of your system.

Originally based on `allosxupdates.sh` from Christopher Allen's .dotfiles -- modified to add some Mac user interface, install fewer tools, and to stand alone without dependencies from other .dotfiles.

> https://github.com/ChristopherA/dotfiles/blob/master/install/allosxupdates.sh


Installation
------------

Ideally install these development tools on a fresh install of macOS "Sierra" 10.3 rather than on an update from a previous version of Mac OS X. This script has been tested in the past with both Mac OS X  "Yosemite" 10.10, "El Capitan" 10.11 and "Sierra" 10.12 but backwards compatibility is not guaranteed.

If not a fresh install, you should at least need to upgrade your Mac to OS X 10.13. If you have ever installed node, python, go or other web development tools from a .dmg installer, you'll need to uninstall those tools first. This script will reinstall them using [HomeBrew](brew.sh).

Execute this command via the Terminal app's command line interface (`command` + `space` + `terminal`):

`curl -L https://raw.githubusercontent.com/ChristopherA/prepare-osx-for-webdev/master/prepare-osx.sh | bash`

WARNING: Be careful about using `curl` piped `|` to `bash` or any other shell as it can compromise your system. Only execute if you trust the source!

After installation, you should edit the `~/.bash_profile.local` file with your own Github credentials. Change the `GIT_AUTHOR_NAME` and `GIT_AUTHOR_EMAIL` to your name and Github account.

If you want to use the suggested _Solarized Dark_ theme for the Terminal app you'll need to change the defaults in Preferences `command + ,`. Under the _Profiles_ tab, select `solarized-dark` and press the 'Default' button.

If this script has not been run on a fresh install of macOS "Sierra" 10.12, after this script is complete you'll need to look for any warnings in the Terminal output, in particular from the `brew doctor` command. If there were any errors, `brew doctor` will tell you how to fix them. If what it suggests to fix the problem doesn't work, I find that almost every problem that has come up is a question on the website [StackOverflow](http://stackoverflow.com/) so search for your solution there.

It is safe to run `brew doctor` or run this entire script multiple times.

If you have an existing `~/.bash_profile` you will need to manually edit this files to set environment variables as per:

> https://github.com/ChristopherA/prepare-osx-for-webdev/blob/master/bash_profile.local


What It Does
------------

The script basically automates parts **2 - Preparation and Installation"** &
**"3 - Customize Your Environment"** from the _Introduction to the Mac Command Line_ tutorial at:

> https://github.com/ChristopherA/intro-mac-command-line

* Installs all macOS System Updates
* Install current macOS "Command Line Tools"
* Installs Homebrew (command line app package tool) http://brew.sh
* Brew Installs:
  * git # http://git-scm.com
  * git-extras # https://github.com/visionmedia/git-extras
  * hub # https://hub.github.com
  * bash-completion # http://bash-completion.alioth.debian.org
  * bash-git-prompt # https://github.com/magicmonty/bash-git-prompt
  * grc # http://korpus.juls.savba.sk/~garabik/software/grc.html
  * wget # https://www.gnu.org/software/wget/
* Installs Caskroom (Mac app package tool) # http://caskroom.io
* Cask Installs:
  * atom # http://atom.io
  * github # https://mac.github.com
* Configures the Mac Terminal
  * Use Solarized theme
* If they don't already exist, creates a minimal:
  * `.bash_profile`
  * `.bash_profile.local`
  * `.gitignore_global`

If you want a more sophisticated Mac command-line web development environment, see:

> https://github.com/ChristopherA/dotfiles/
