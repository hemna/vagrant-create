#!/bin/bash
# Script that looks in ~/images/vagrant for vagrant box images,
# then prompts you which one you want to add to your vagrant box list.
# This script installs the vagrant box images into vagrant's list of known
# images to use for starting a new vagrant.   

# get the menu function
SCRIPTDIR=$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")
source $SCRIPTDIR/menu.sh

IMAGES_DIR="$HOME/images/vagrant"

if [ -d "$IMAGES_DIR" ]
then
    cd $IMAGES_DIR
    files=$(find "${IMAGES_DIR}" -mindepth 1 -maxdepth 1 -type f -print0 | xargs -0 -i echo "{}" | sort)
    BOX_PATH=$(menu 'Select Box to add:' $files)
    [[ -n $BOX_PATH ]] || exit 1      # user selected cancel
    BOX_FILENAME=$(basename "$BOX_PATH")
    BOX_NAME="${BOX_FILENAME%.*}"
    echo "Installing box $BOX_NAME"
   
    vagrant box add --provider libvirt $BOX_NAME $BOX_PATH
else
    echo "Doesn't look like you have '$IMAGES_DIR' location."
    echo "Please create '$IMAGES_DIR' and copy a vagrant box image here."
    exit 1
fi

