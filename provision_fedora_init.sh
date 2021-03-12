#!/bin/bash

PLAY_USER="$USER"

function GTERM_LOAD()
{
   GTERM_DIR="$HOME/.gterm"
   GTERM_FILE="$GTERM_DIR/gterm-profile.dconf"
   GTERM_RC="$GTERM_DIR/gterm.rc"
   GTERM_URL="https://raw.githubusercontent.com/rm-tic/provision-fedora/master/gterm-profile.dconf"

   if [[ ! -d $GTERM_DIR  || "$(cat $GTERM_RC)" != "0" ]]; then
   
      mkdir $GTERM_DIR
      echo "0" > $GTERM_RC

      wget -qO $GTERM_FILE $GTERM_URL

      #DCONF EXPORT
      #dconf dump /org/gnome/terminal/legacy/profiles:/ > $GTERM_FILE

      #DCONF IMPORT
      dconf load /org/gnome/terminal/legacy/profiles:/ < $GTERM_FILE

   fi

}

function CHECK_INSTALL()
{
   PKG="$(rpm -qa $1)"

   if [ ! -z "$PKG" ]; then
      echo "present"
   else
      echo "absent"
   fi
}

function INSTALL()
{
   GIT_STATUS="$(CHECK_INSTALL git)"
   CURL_STATUS="$(CHECK_INSTALL curl)"
   PYTHON3_VENV_STATUS="$(CHECK_INSTALL python3-virtualenv)"
   PYTHON3_PSUTIL_STATUS="$(CHECK_INSTALL python3-psutil)"
   PYTHON3_PIP_STATUS="$(CHECK_INSTALL python3-pip)"

   echo "Installing Essential Packages..."
   echo

   if [ "$GIT_STATUS" = "absent" ]; then
      sudo dnf install -y git &>/dev/null
      echo ">> Git v$(git --version | awk '{print $3}') installed."
   else
      echo ">> Git is already installed."
   fi

   if [ "$CURL_STATUS" = "absent" ]; then
      sudo dnf install -y curl &>/dev/null
      echo ">> curl installed."
   else
      echo ">> curl is already installed."
   fi

   if [ "$PYTHON3_VENV_STATUS" = "absent" ]; then
      sudo dnf install -y python3-virtualenv &>/dev/null
      echo ">> python3-virtualenv installed."
   else
      echo ">> python3-virtualenv is already installed."
   fi

   if [ "$PYTHON3_PSUTIL_STATUS" = "absent" ]; then
      sudo dnf install -y python3-psutil &>/dev/null
      echo ">> python3-psutil installed."
   else
      echo ">> python3-psutil is already installed."
   fi

   if [ "$PYTHON3_PIP_STATUS" = "absent" ]; then
      sudo dnf install -y python3-pip &>/dev/null
      echo ">> python3-pip installed."
   else
      echo ">> python3-pip is already installed."
   fi

   echo

}

function CLONE_REPO()
{
   REPO_DIR="/tmp/provision-fedora"
   REPO_URL="https://github.com/rm-tic/provision-fedora.git"

   echo "Cloning Repository in $REPO_DIR"

   git clone $REPO_URL $REPO_DIR &>/dev/null

   echo
}

function CREATE_VENV()
{
   python3 -m venv "$REPO_DIR/.venv"
}

function ENABLE_VENV()
{
   . "$REPO_DIR/.venv/bin/activate"
}

function SETUP_VENV()
{
   python3 -m pip install --upgrade pip > /dev/null 2>&1
   python3 -m pip install ansible > /dev/null 2>&1
}

function EXEC_ANSIBLE()
{
   echo
   echo "Starting Playbook..."
   echo
   ansible-playbook -i "$REPO_DIR/hosts" "$REPO_DIR/main.yml"
}

function MAIN()
{

   echo
   echo "+------------------------------------+"
   echo "| Invencible (Ansible)               |"
   echo "+------------------------------------+"
   echo "| Project : provision-fedora         |"
   echo "| Author  : Rodrigo Martins (IceTux) |"
   echo "| Updated : 2021-03-11               |"
   echo "+------------------------------------+"
   echo
   echo

   #Exec Functions
   GTERM_LOAD
   INSTALL
   CLONE_REPO
   CREATE_VENV
   ENABLE_VENV
   SETUP_VENV
   EXEC_ANSIBLE

}


MAIN