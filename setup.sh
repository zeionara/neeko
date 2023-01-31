#!/bin/bash

quit () {
    echo $1
    exit 1
}

local_installer_path=/tmp/ballerina-installer.deb

wget https://dist.ballerina.io/downloads/2201.3.2/ballerina-2201.3.2-swan-lake-linux-x64.deb -O $local_installer_path || quit 'Cannot download installer'
sudo dpkg -i $local_installer_path || quit 'Cannot install ballerina'
rm $local_installer_path || quit 'Cannot remove installer'
