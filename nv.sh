#!/bin/bash
# script that creates a new vagrant in ~/vagrant/<name>

# For debugging this script -- skips the slow stuff (vagrant box list, git clone, vagrant up)
# DEBUG=1

# Capture dir in which this script lives
SCRIPTDIR=$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")

# get the menu function
source $SCRIPTDIR/menu.sh

BASE_PATH="$HOME/vagrant"
VAGRANT_NAME=""
VAGRANT_BOX=""
START_VAGRANT=0
BYPASS_DEVSTACK="false"
VM_RAM=8192
VM_CPUS=2
VM_HOSTNAME="devstack"
HD_SIZE=1

usage() {
    cat <<EOF
usage: $0 options

OPTIONS:
    -b      Bypass devstack? (Default: No)
    -d      Size of boot disk (Defaults to vm image size)
    -c      Number of CPUS (Default: 2)
    -l      Local.conf to use
    -m      Amount of ram for the vm (Default: 8192)
    -n      Name of the vagrant
    -s      Automatically start the vagrant? (Default: no)

    -h      this help output
EOF
}

while getopts "sn:h:m:c:d:bl:" OPTION
do
    case $OPTION in
        n)
            echo "using {$OPTARG} as vagrant name"
            VAGRANT_NAME=$OPTARG
            VM_HOSTNAME="$VAGRANT_NAME-vm"
            ;;
        s)
            echo "Starting Vagrant after build"
            START_VAGRANT=1
            ;;
        c)
            echo "VM CPUS {$OPTARG}"
            VM_CPUS=$OPTARG
            ;;
        d)
            echo "HD SIZE {$OPTARG}"
            HD_SIZE=$OPTARG
            ;;
        m)
            echo "VM RAM {$OPTARG}"
            VM_RAM=$OPTARG
            ;;
        b)
            echo "Bypass devstack"
            BYPASS_DEVSTACK="true"
            ;;
        h)
            usage
            exit
            ;;
        l)
            echo "Local conf ${OPTARG}"
            LOCAL_CONF=$OPTARG
            ;;
        ?)
            usage
            exit
            ;;
    esac
done
# Remove all processed options from command line args
shift $((OPTIND-1))

if [ -z "$VAGRANT_NAME" ]; then
    echo "You must specify the vagrant name"
    usage
    exit
fi

VAGRANT_PATH="$BASE_PATH/$VAGRANT_NAME"
if [ -d "$VAGRANT_PATH" ]; then
    echo "Vagrant ${VAGRANT_NAME} already exists"
    exit
fi

# Get a list of available vagrant boxes
if [[ $DEBUG -eq 1 ]] ; then
    boxes="boxone boxtwo boxthree"
else
    boxes=$(vagrant box list | grep libvirt | awk '{print $1}')
fi

if [[ -z $boxes ]] ; then
    echo "No boxes are available" >&2
    exit 1
fi

# Display menu of available boxes
BOX_NAME=$(menu 'Available boxes:' $boxes)
[[ -n $BOX_NAME ]] || exit 1     # exit if user cancelled

# now clone the repository
cd $BASE_PATH
if [[ $DEBUG -eq 1 ]] ; then
    mkdir -p $VAGRANT_NAME/files/home
else
    git clone https://github.com/hemna/vagrant-devstack.git $VAGRANT_NAME
fi

cd $VAGRANT_NAME

# link to dot files in home dir
for file in .bashrc .vim .vimrc .gitconfig .liquidprompt ; do
    if [ -e $HOME/$file ] ; then
        ln -s $HOME/$file files/home
    fi
done


cat > config.yaml <<CONFIG_YAML
box: $BOX_NAME
hostname: $VM_HOSTNAME
memory: $VM_RAM
cpus: $VM_CPUS
bypass_devstack: $BYPASS_DEVSTACK
install_powerline: true
forward_x11: true
extra_packages: ack-grep
hdsize: $HD_SIZE
CONFIG_YAML


# Prompt for which local.conf to use
if [[ -z $LOCAL_CONF ]] ; then
    conf="(default) "
    conf+=$(ls -1 ${SCRIPTDIR}/conf | grep ^local.conf)
    LOCAL_CONF=$(menu 'Available local.confs:' $conf)
    [[ -n $LOCAL_CONF ]] || exit 1     # exit if user cancelled
fi

if [[ $LOCAL_CONF != "(default)" ]] ; then
    cp ${SCRIPTDIR}/conf/$LOCAL_CONF files/local.conf
fi

if [ $START_VAGRANT -ne 0 ]
then
    echo "Starting Vagrant"
    [[ $DEBUG -eq 1 ]] || vagrant up
else
    echo "Not starting vagrant"
fi
