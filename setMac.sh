#!/bin/sh

# Xcode
xcode-select --install


##GIT
git config --global core.excludesfile ~/.gitignore
git config --global user.name "bipulkkuri"
git config --global user.email "3050036+bipulkkuri@users.noreply.github.com"
git config --global color.ui true
#git pr 12
git config --global --add alias.pr '!f() { git fetch -fu ${2:-upstream} refs/pull/$1/head:pr/$1 && git checkout pr/$1; }; f'
git config --global --add alias.pr-clean '!git checkout master ; git for-each-ref refs/heads/pr/* --format="%(refname)" | while read ref ; do branch=${ref#refs/heads/} ; git branch -D $branch ; done'


### set vim plugin ###
git clone https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
cd ~/.vim_runtime && git pull --rebase && cd -

##BREW
# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi


function prompt {
  if [[ -z "${CI}" ]]; then
    read -p "Hit Enter to $1 ..."
  fi
}


function install {
  cmd=$1
  shift
  for pkg in "$@";
  do
    exec="$cmd $pkg"
    #prompt "Execute: $exec"
    if ${exec} ; then
      echo "Installed $pkg"
    else
      echo "Failed to execute: $exec"
      if [[ ! -z "${CI}" ]]; then
        exit 1
      fi
    fi
  done
}

function brew_install_or_upgrade {
  if brew ls --versions "$1" >/dev/null; then
    if (brew outdated | grep "$1" > /dev/null); then
      echo "Upgrading already installed package $1 ..."
      brew upgrade "$1"
    else
      echo "Latest $1 is already installed"
    fi
  else
    brew install "$1"
  fi
}


brews=(
  awscli
  "bash-snippets --without-all-tools --with-cryptocurrency --with-stocks --with-weather"
  bat
  #cheat
  coreutils
  dfc
  exa
  findutils
  "fontconfig --universal"
  fpp
  git
  git-extras
  git-fresh
  git-lfs
  gpg
  htop
  httpie
  homebrew/cask/java
  iftop
  m-cli
  mas
  moreutils
  mtr
  mycli
  ncdu
  neofetch
  nmap
  openssh
  packer
  pv
  pidof
  shellcheck
  sonar-scanner
  stormssh
  sqlmap
  tmux
  tree
  wget
  xsv
)

brew update && brew upgrade
prompt "Install packages"
install 'brew_install_or_upgrade' "${brews[@]}"


echo "Cleaning up brew"
brew upgrade brew
brew cleanup

#Setup the alias in HOME
cp .aliases ~/.aliases
cp .functions ~/.functions

cat <<EOT >> ~/.bash_profile
if [ -f ~/.aliases ]; then
  . ~/.aliases
fi

# Load my functions
if [ -f ~/.functions ]; then
  . ~/.functions
fi
EOT


cat <<EOFS >> ~/.vimrc

" Display options
set showmode

" Turn on syntax highlighting.
syntax on

" Automatically wrap text that extends beyond the screen length.
set wrap

" Show line numbers
set number


" Color scheme (terminal)
set t_Co=256
set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1
EOFS

