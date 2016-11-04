#!/bin/bash
# Script that helps a user remove a box from the vagrant box list.

# get the menu function
SCRIPTDIR=$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")
source $SCRIPTDIR/menu.sh

IMAGES_DIR="$HOME/images/vagrant"

boxes=$(vagrant box list | grep libvirt | awk '{print $1}')
BOX_NAME=$(menu 'Select Box to add:' $boxes)
[[ -n $BOX_NAME ]] || exit 1      # user selected cancel
echo "Removing $BOX_NAME from vagrant box list"
vagrant box remove --provider libvirt $BOX_NAME 
