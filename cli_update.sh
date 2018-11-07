#!/bin/bash
#
# Update script for CLI, applying latest version
curl -fL https://getcli.jfrog.io | sh

sleep 5
mv ~/Work/cli/jfrog /usr/local/bin

sleep 1
chmod 777 /usr/local/bin/jfrog

sleep 1
echo "Successfully installed"
jfrog --version
