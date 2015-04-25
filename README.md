Prepare OSX for WebDev
======================

Simple script to prepare OSX for web development and command-line tools:
    https://github.com/ChristopherA/prepare-osx-for-webdev

Originally based on Christopher Allen's dotfiles:
    https://github.com/ChristopherA/dotfiles/blob/master/install/allosxupdates.sh

Modified to only install basic command-line utilities and webdev files,
such as node, without dependencies on other install files

Execute on a new machine via:

`curl -L https://raw.githubusercontent.com/ChristopherA/prepare-osx-for-webdev/master/prepare-osx-for-webdev.sh | bash`

WARNING: Be careful about using `curl` piped `|` to `bash` or any other shell
as it can compromise your system. Only execute if you trust the source!
