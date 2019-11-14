#!/bin/sh
set -e

configs=$HOME/configs

# SETUP CONFIG FILES
#
# loops through all files in the 'configs' folder and performs an envsubst
# with the current environment

for file in $configs/*; do envsubst < $file > $file; done

bash -c "$1"
