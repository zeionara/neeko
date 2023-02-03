#!/bin/bash

quit () {
    echo $1
    exit 1
}

install_ballerina () {
    local_installer_path=${1:-/tmp/ballerina-installer.deb}

    wget https://dist.ballerina.io/downloads/2201.3.2/ballerina-2201.3.2-swan-lake-linux-x64.deb -O $local_installer_path || quit 'Cannot download installer'
    sudo dpkg -i $local_installer_path || quit 'Cannot install ballerina'
    rm $local_installer_path || quit 'Cannot remove installer'
}

install_git_lfs () {
    git_lfs_folder=${1:-git-lfs-3.3.0}
    local_installer_path=${2:-/tmp/git-lfs.tar.gz}

    wget https://github.com/git-lfs/git-lfs/releases/download/v3.3.0/git-lfs-linux-amd64-v3.3.0.tar.gz -O $local_installer_path
    tar -xzvf $local_installer_path
    rm $local_installer_path

    cd $git_lfs_folder
    sudo ./install.sh

    rm -rf $git_lfs_folder

    git lfs install
}

bal --version || install_ballerina
git lfs install || install_git_lfs
