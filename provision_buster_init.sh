#!/bin/bash

PLAY_USER="$USER"

function CHECK_INSTALL()
{

   PKG="$(dpkg-query -W -f='${db:Status-Abbrev}' $1 2> /dev/null | cut -c 1-2)"

   if [ "$PKG" = "ii" ]; then

      echo "present"

   else

      echo "absent"

   fi

}

function APT_UPDATE()
{

   if [ "$UPDATE_RC" != "0" ]; then

      sudo apt-get update -qq
      UPDATE_RC="0"

   fi

}

function INSTALL()
{

   GIT_STATUS="$(CHECK_INSTALL git)"
   PYTHON3_VENV_STATUS="$(CHECK_INSTALL python3-venv)"
   PYTHON3_PSUTIL_STATUS="$(CHECK_INSTALL python3-psutil)"
   PYTHON3_PIP_STATUS="$(CHECK_INSTALL python3-pip)"
   CURL_STATUS="$(CHECK_INSTALL curl)"

   echo "Installing Essential Packages..."
   echo


   if [ "$CURL_STATUS" = "absent" ]; then

      APT_UPDATE
      sudo apt-get install -y curl > /dev/null 2>&1
      echo ">> curl installed."

   else

      echo ">> curl is already installed."

   fi

   if [ "$PYTHON3_VENV_STATUS" = "absent" ]; then

      APT_UPDATE
      sudo apt-get install -y python3-venv > /dev/null 2>&1
      echo ">> python3-venv installed."

   else

      echo ">> python3-venv is already installed."

   fi

   if [ "$PYTHON3_PSUTIL_STATUS" = "absent" ]; then

      APT_UPDATE
      sudo apt-get install -y python3-psutil > /dev/null 2>&1
      echo ">> python3-psutil installed."

   else

      echo ">> python3-psutil is already installed."

   fi

   if [ "$PYTHON3_PIP_STATUS" = "absent" ]; then

      APT_UPDATE
      sudo apt-get install -y python3-pip > /dev/null 2>&1
      echo ">> python3-pip installed."

   else

      echo ">> python3-pip is already installed."

   fi

   if [ "$GIT_STATUS" = "absent" ]; then

      APT_UPDATE
      sudo apt-get install -y git > /dev/null 2>&1
      echo ">> Git v$(git --version | awk '{print $3}') installed."

   else

      echo ">> Git is already installed."

   fi

   echo

}

function CLONE_REPO()
{
   REPO_DIR="/tmp/provision-buster"
   REPO_URL="https://github.com/rm-tic/provision-buster.git"

   echo "Cloning Repository in $REPO_DIR"

   git clone $REPO_URL $REPO_DIR > /dev/null 2>&1

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
   echo "|------------------------------------|"
   echo "| Project : provision-buster         |"
   echo "| Author  : Rodrigo Martins (IceTux) |"
   echo "| Updated : 2021-02-27               |"
   echo "+------------------------------------+"
   echo
   echo

   #Exec Functions
   INSTALL
   CLONE_REPO
   CREATE_VENV
   ENABLE_VENV
   SETUP_VENV
   EXEC_ANSIBLE

}


MAIN