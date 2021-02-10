#!/bin/bash
echo "I am running as $(whoami)"

sudo curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec
inspec -v
