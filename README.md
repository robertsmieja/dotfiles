# dotfiles
Personal dotfiles

## Shell profile scripts

ZSH will load the following files, in order:
1. $ZDOTDIR/.zshenv
1. $ZDOTDIR/.zprofile
    1. $HOME/.profile
1. $ZDOTDIR/.zshrc

Bash will load the following files in order:
1. $HOME/.bash_profile
  1. $HOME/.profile
1. $HOME/.bashrc
  1. $HOME/.profile

### More info
See the following for more information on ordering:
* https://wiki.archlinux.org/title/Bash#Configuration_files
* https://wiki.archlinux.org/title/Zsh#Startup/Shutdown_files
