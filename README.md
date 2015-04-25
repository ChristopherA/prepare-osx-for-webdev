Prepare OSX for WebDev
======================

Script to prepare Mac OSX with basic command-line tools and for web development:
    https://github.com/ChristopherA/prepare-osx-for-webdev

This installer basically automates parts **2 - Preparation and Installation"** &
**"3 - Customize Your Environment"** from the _Introduction to the Mac Command Line_ tutorial at:
    https://github.com/ChristopherA/intro-mac-command-line

Originally based on `allosxupdates.sh` from Christopher Allen' dotfiles:
    https://github.com/ChristopherA/dotfiles/blob/master/install/allosxupdates.sh

Modified to install only basic command-line utilities and web development packages, such as node, without dependencies on other files. If you want a more sophisticated Mac command-line web development environment, see:
    https://github.com/ChristopherA/dotfiles/

Installation
------------

Execute on a new machine via:

`curl -L https://raw.githubusercontent.com/ChristopherA/prepare-osx-for-webdev/master/prepare-osx-for-webdev.sh | bash`

WARNING: Be careful about using `curl` piped `|` to `bash` or any other shell as it can compromise your system. Only execute if you trust the source!

What It Does
------------

* Installs all Mac OSX System Updates
* Install current "OSX Command Line Tools"
* Installs Homebrew (command line app package tool) http://brew.sh
* Brew Installs:
  * git # http://git-scm.com
  * git-extras # https://github.com/visionmedia/git-extras
  * hub # https://hub.github.com
  * bash-completion # http://bash-completion.alioth.debian.org
  * bash-git-prompt # https://github.com/magicmonty/bash-git-prompt
  * grc # http://korpus.juls.savba.sk/~garabik/software/grc.html
  * wget # https://www.gnu.org/software/wget/
  * node # https://nodejs.org/
* Installs Caskroom (Mac app package tool) # http://caskroom.io
* Cask Installs:
  * atom # http://atom.io
  * github # https://mac.github.com
* Configures the Mac Terminal
  * Use Solarized theme
* If they don't already exist, creates:
  * `.bash_profile`
  * `.bash_profile.local`
  * `.gitignore_global`
