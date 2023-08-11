#!/bin/bash

set -e

lsb_release -a

architecture=$(dpkg --print-architecture)

filename=".robotchain/config.robotchain"
if [ ! -f "$filename" ]; then
    exit 0
fi

type=$(jq -r ".type" "$filename")
title=$(jq -r ".title" "$filename")
version=$(jq -r ".version" "$filename")
if [ -z "$type" ] || [ -z "$title" ] || [ -z "$version" ]; then
  exit 1
fi

if [ ! -d "debian" ]; then
    mkdir -p debian
    mkdir -p debian/DEBIAN
    mkdir -p debian/opt/tros/lib
    mkdir -p debian/opt/tros/share
    mkdir -p debian/opt/tros/lib
    mkdir -p debian/opt/tros/include
    mkdir -p debian/opt/robotchain/manager
else
    sudo rm -rf debian
    mkdir -p debian
    mkdir -p debian/DEBIAN
    mkdir -p debian/opt/tros/lib
    mkdir -p debian/opt/tros/share
    mkdir -p debian/opt/tros/lib
    mkdir -p debian/opt/tros/include
    mkdir -p debian/opt/robotchain/manager
fi

echo -e "\033[32mStarting to build the deb software package for you...\033[0m"

colcon build --packages-select rosapi_msgs
colcon build --packages-select rosbridge_msgs
colcon build --packages-select rosbridge_test_msgs
colcon build --packages-select rosbridge_library
colcon build --packages-select rosapi
colcon build --packages-select rosbridge_server
colcon build --packages-select rosbridge_suite

echo -e "\033[32mPublishing the deb software package to the software repository server for you...\033[0m"

sudo cp -r .robotchain debian/opt/robotchain/manager/"${type}"/"${title}"/

sudo cp -r install/rosapi/lib/* debian/opt/tros/lib/
sudo cp -r install/rosapi/share/* debian/opt/tros/share/
sudo cp -r install/rosapi_msgs/lib/* debian/opt/tros/lib/
sudo cp -r install/rosapi_msgs/include/* debian/opt/tros/include/
sudo cp -r install/rosapi_msgs/share/* debian/opt/tros/share/
sudo cp -r install/rosbridge_library/lib/* debian/opt/tros/lib/
sudo cp -r install/rosbridge_library/share/* debian/opt/tros/share/
sudo cp -r install/rosbridge_msgs/lib/* debian/opt/tros/lib/
sudo cp -r install/rosbridge_msgs/include/* debian/opt/tros/include/
sudo cp -r install/rosbridge_msgs/share/* debian/opt/tros/share/
sudo cp -r install/rosbridge_server/lib/* debian/opt/tros/lib/
sudo cp -r install/rosbridge_server/share/* debian/opt/tros/share/
sudo cp -r install/rosbridge_suite/share/* debian/opt/tros/share/
sudo cp -r install/rosbridge_test_msgs/lib/* debian/opt/tros/lib/
sudo cp -r install/rosbridge_test_msgs/include/* debian/opt/tros/include/
sudo cp -r install/rosbridge_test_msgs/share/* debian/opt/tros/share/

sudo touch debian/DEBIAN/control && sudo chmod +x debian/DEBIAN/control
standard_package_name=$(echo "$title" | tr "_" "-")
standard_package_name=$(echo "$standard_package_name" | tr '[:upper:]' '[:lower:]')
name_str="Package: $standard_package_name"
export name_str
sudo -E sh -c 'echo $name_str >> debian/DEBIAN/control'
version_str="Version: $version"
export version_str
sudo -E sh -c 'echo $version_str >> debian/DEBIAN/control'
sudo sh -c 'echo "Maintainer: GEEKROS <admin@geekros.com>" >> debian/DEBIAN/control'
sudo sh -c 'echo "Homepage: https://www.geekros.com" >> debian/DEBIAN/control'
architecture_str="Architecture: $architecture"
export architecture_str
sudo -E sh -c 'echo $architecture_str >> debian/DEBIAN/control'
sudo sh -c 'echo "Installed-Size: 5000" >> debian/DEBIAN/control'
sudo sh -c 'echo "Section: utils" >> debian/DEBIAN/control'
sudo sh -c 'echo "Depends: git" >> debian/DEBIAN/control'
sudo sh -c 'echo "Description: robotchain and robot" >> debian/DEBIAN/control'

sudo dpkg --build debian/ && dpkg-name debian.deb

# shellcheck disable=SC2035
sudo rm -rf debian && robotchain package publish && sudo rm -rf *.deb