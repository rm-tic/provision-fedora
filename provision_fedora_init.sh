#!/bin/bash

# Author: Rodrigo Martins
# E-mail: rodrigomartins.tic@gmail.com


function dnf_cache(){
   dnf makecache -q
}

function pkg_setup(){
   local PKG="$1"

   type -P $PKG &>/dev/null && local PKG_STATUS="OK" || local PKG_STATUS="NOK"

   if [ "$PKG_STATUS" = "NOK" ]; then
      $sh_c 'dnf install -y '$PKG' > /dev/null 2>&1'
      echo ">>> Package: $PKG installed"
   else
      echo ">>> Package: $PKG is already installed"
   fi
}

function gh_clone_repo(){
   REPO_DIR="/tmp/provision-fedora"
   REPO_URL="https://github.com/rm-tic/provision-fedora.git"

   echo ">>> Cloning repository in $REPO_DIR..."
   echo
   git clone $REPO_URL $REPO_DIR > /dev/null 2>&1
}

function python_venv_create(){
   echo ">>> Creating python3 virtualenv..."
   python3 -m virtualenv -q "$REPO_DIR/.venv"
}

function python_venv_activate(){
   echo ">>> Enabling virtualenv..."
   echo
   source "$REPO_DIR/.venv/bin/activate"
}

function python_venv_setup(){
   echo ">>> Installing playbook dependencies via pip..."
   echo
   python3 -m pip -q install -U -r "$REPO_DIR/reqs.txt"
}

function ansible_collections(){
   echo ">>> Ansible: Install community.general collection"
   echo
   ansible-galaxy collection install community.general > /dev/null 2>&1
}

function ansible_run(){
   echo ">>> Ansible: Starting playbook..."
   echo
   ansible-playbook "$REPO_DIR/main.yml"
}

function main(){

   if [ "$(id -un)" = "root" ]; then
      sh_c="sh -c"
   else
      sh_c="sudo sh -c"
   fi

   echo
   echo "+----------------------------------+"
   echo "| Invencible (Ansible)             |"
   echo "| Project: provision-fedora        |"
   echo "| Author: Rodrigo Martins (IceTux) |"
   echo "| Creation Date: 2022-10-18        |"
   echo "+----------------------------------+"
   echo
   echo

   # Install Essential Packages
   dnf_cache
   pkg_setup git
   pkg_setup curl
   pkg_setup python3-virtualenv
   
   # Load Functions
   gh_clone_repo
   python_venv_create
   python_venv_activate
   python_venv_setup
   ansible_collections
   ansible_run
}

main $@