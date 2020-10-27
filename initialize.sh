#!/usr/bin/env bash

# some bash library helpers
# @author Adam Eivy https://github.com/atomantic/dotfiles

debug=${1:-false} # default debug param.

# --------------------
# Console Print Styles
# --------------------

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"\e[96m"

function ok() {
  echo -e "$COL_GREEN[ok]$COL_RESET $1"
}

function botintro() {
  echo -e "\n$COL_BLUE(っ◕‿◕)っ$COL_RESET - $1"
}
function bot() {
  echo -e "$COL_BLUE(っ◕‿◕)っ$COL_RESET - $1"
}

function actioninfo() {
  echo -e "$COL_YELLOW[action]:$COL_RESET ⇒ $1"
}

function running() {
  echo -en "$COL_YELLOW ⇒ $COL_RESET $1: "
}

function action() {
  echo -e "\n$COL_YELLOW[action]:$COL_RESET ⇒ $1"
}

function warn() {
  echo -e "$COL_YELLOW[warning]$COL_RESET $1"
}

function success() {
  echo -e "$COL_GREEN[success]$COL_RESET $1"
}

function error() {
  echo -e "$COL_RED[error]$COL_RESET $1"
}

function cancelled() {
  echo -e "$COL_RED[cancelled]$COL_RESET $1"
}

function awesome_header() {
  echo -en "\n$COL_BLUE          ██            ██     ████ ██  ██ $COL_RESET"
  echo -en "\n$COL_BLUE         ░██           ░██    ░██░ ░░  ░██ $COL_RESET"
  echo -en "\n$COL_BLUE         ░██  ██████  ██████ ██████ ██ ░██  █████   ██████ $COL_RESET"
  echo -en "\n$COL_BLUE      ██████ ██░░░░██░░░██░ ░░░██░ ░██ ░██ ██░░░██ ██░░░░ $COL_RESET"
  echo -en "\n$COL_BLUE     ██░░░██░██   ░██  ░██    ░██  ░██ ░██░███████░░█████ $COL_RESET"
  echo -en "\n$COL_BLUE    ░██  ░██░██   ░██  ░██    ░██  ░██ ░██░██░░░░  ░░░░░██ $COL_RESET"
  echo -en "\n$COL_BLUE    ░░██████░░██████   ░░██   ░██  ░██ ███░░██████ ██████ $COL_RESET"
  echo -en "\n$COL_BLUE     ░░░░░░  ░░░░░░     ░░    ░░   ░░ ░░░  ░░░░░░ ░░░░░░ $COL_RESET"
  echo -en "\n"
  echo -en "\n"
}

ask_for_confirmation() {
  echo -e "\e[1m$1\e[0m (y/N) "
  read -n 1
  echo -e "\n"
}

answer_is_yes() {
  [[ "$REPLY" =~ ^(y|Y) ]] && return 0 || return 1
}

print_result() {
  [ $1 -eq 0 ] && success "$2" || error "$2"
  [ "$3" == "true" ] && [ $1 -ne 0 ] && exit
}

execute() {
  if $debug; then
    $1
  else
    $1 &>/dev/null
  fi
  print_result $? "${2:-$1}"
}

# Check if folder is a git repo.
is_git_repository() {
  [ "$(
    git rev-parse &>/dev/null
    printf $?
  )" -eq 0 ] && return 0 || return 1
}

ask_for_sudo() {
  # Ask for the administrator password upfront
  sudo -v

  # Update existing `sudo` time stamp until this script has finished
  # https://gist.github.com/cowboy/3118588
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &>/dev/null &
}

# ----
# Prep
# ----
echo -e "\n\e[1m\$📦 Mac Setup by [Murshid Azher](https://github.com/murshidazher/dotfiles)  /~\n\e[0m"

defaultdotfilesdir="$HOME/dotfiles"
dotfilesdir=$(pwd)

#if is_git_repository; then
# git pull origin master # pull repo.
#fi;

warn "\e[1mEnsure your mac system is fully up-to-date and only\e[0m"
warn "\e[1mrun this script in terminal.app (NOT in iTerm)\e[0m"
warn "\e[1mrun this script on ~ or ~/dev/src/github\e[0m"
warn "=> \e[1mCTRL+C now to abort\e[0m or \e[1mENTER\e[0m to continue."
tput bel
read -n 1

# Introduction
awesome_header

botintro "This script sets up new machines, \e[1m*use with caution*\e[0m. Please go read the script, it only takes a few minutes, [https://github.com/murshidazher/dotfiles]."
echo -e "\nPress \e[1mENTER\e[0m to continue."
read -n 1

botintro "To start we'll need your password.\n"

tput bel

ask_for_confirmation "Ready?"
if answer_is_yes; then
  ok "\e[1mLet's go.\e[0m"
else
  cancelled "\e[1mExit.\e[0m"
  exit -1
fi

#exit -1

# Ask for the administrator password upfront.
ask_for_sudo

# Source directories and files to handle.
source ./setup/files.sh

# Install all available macos updates.
#action "Installing Mac updates:\n"
#sudo softwareupdate -ia

#-------------------------------------------
# Prerequisite: Login to Github
# Generate ssh keys & add to ssh-agent
# See: https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
#-------------------------------------------

botintro "Generating ssh keys, adding to ssh-agent..."
read -p 'Input email for ssh key: ' useremail

botintro "Use default ssh file location, enter a passphrase: "
ssh-keygen -t rsa -b 4096 -C "$useremail" # will prompt for password
eval "$(ssh-agent -s)"

# Now that sshconfig is synced add key to ssh-agent and
# store passphrase in keychain
ssh-add -K ~/.ssh/id_rsa

# If you're using macOS Sierra 10.12.2 or later, you will need to modify your ~/.ssh/config file to automatically load keys into the ssh-agent and store passphrases in your keychain.

if [ -e ~/.ssh/config ]; then
  botintro "ssh config already exists. Skipping adding osx specific settings... "
else
  botintro "Writing osx specific settings to ssh config... "
  cat <<EOT >>~/.ssh/config
	Host *
		AddKeysToAgent yes
		UseKeychain yes
		IdentityFile ~/.ssh/id_rsa
EOT
fi

#-------------------------------------------
# Add ssh-key to GitHub via api
#-------------------------------------------

botintro "Adding ssh-key to GitHub (via api)..."
botintro "Important! For this step, use a github personal token with the admin:public_key permission."
botintro "If you don't have one, create it here: https://github.com/settings/tokens/new"

retries=3
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

for ((i = 0; i < retries; i++)); do
  read -p 'GitHub username: ' ghusername
  read -p 'Machine name: ' ghtitle
  read -sp 'GitHub personal token: ' ghtoken

  gh_status_code=$(curl -o /dev/null -s -w "%{http_code}\n" -u "$ghusername:$ghtoken" -d '{"title":"'$ghtitle'","key":"'"$SSH_KEY"'"}' 'https://api.github.com/user/keys')

  if (($gh_status_code - eq == 201)); then
    botintro "GitHub ssh key added successfully!"
    break
  else
    botintro "Something went wrong. Enter your credentials and try again..."
    botintro -n "Status code returned: "
    botintro $gh_status_code
  fi
done

[[ $retries -eq i ]] && botintro "Adding ssh-key to GitHub failed! Try again later."

#-------------------------------------------
# Install dotfiles repo, run link script
#-------------------------------------------

if [ -e $HOME/dev/src/github ]; then
  botintro "Create a dev directory on root"
  mkdir -p $HOME/dev/src/github
else
  botintro "~/dev directory exists..."
fi

botintro "Cloning the repo from https://github.com/murshidazher/dotfiles to ~/dev/src/github"

# dotfiles for vs code, emacs, gitconfig, oh my zsh, etc.
cd $HOME/dev/src/github
gh_clone=$(git clone git@github.com:murshidazher/dotfiles.git)

if (!($gh_clone)); then
  botintro "Something went wrong. When cloning the repo..."
  botintro -n "Status code returned: "
  botintro $gh_clone
  break
else
  botintro "Dotfile cloned successfully..."
  cd dotfiles
  botintro "Setting up...."

  # dotfiles for vs code, emacs, gitconfig, oh my zsh, etc.
  ./setup.sh
fi

# EOF
