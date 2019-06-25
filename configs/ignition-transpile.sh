#!/bin/bash

# This is supposed ct is installed
# To install it, go to https://github.com/coreos/container-linux-config-transpiler

PLATFORM=${1:-ec2}

set -xe

for yml_file in $(ls *.yml); do
    file_name=$(echo "$yml_file" | cut -f 1 -d '.')
    ct -platform $PLATFORM -in-file $yml_file -out-file ignition/${file_name}.json
done