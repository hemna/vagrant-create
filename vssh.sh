#!/bin/bash

# Performs the equivalent of 'vagrant ssh', but
# caches the ssh information so that it operates
# MUCH faster.
#
# Usage:
#    vssh.sh


if ! git rev-parse &> /dev/null; then
    echo "Need to be somewhere vagrant tree";
    return;
fi;
topdir=$(git rev-parse --show-toplevel);
if [ ! -f $topdir/Vagrantfile ]; then
    echo "Need to be somewhere vagrant tree";
    return;
fi;
host=$(basename $topdir);
if [ ! -f $topdir/.vssh ]; then
    vagrant ssh-config > $topdir/.vssh;
fi;
ssh -F $topdir/.vssh "$@" devstack
