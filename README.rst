Vagrant Creation Helper
=======================
This project contains a helper bash script that does a lot of the repepetive
work of creating new vagrants with all of the config options that we use for 
devstack based development. 


What the script does
====================
* clones the vagrant-devstack git repository
* automatically discovers existing vagrant boxes
* prompts user for which vagrant box to use
* sets up the config.yaml file depending on options pass at command line
* sets up the files/home symlinks to typical things like ~/.vimrc, ~/.vim
* optionally starts the vagrant
