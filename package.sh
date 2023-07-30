#!/bin/bash

set -e

lsb_release -a

filename=".robotchain/package.json"
if [ ! -f "$filename" ]; then
    exit 0
fi

type=$(jq -r ".type" "$filename")
if [ -z "$type" ]; then
    exit 1
fi

title=$(jq -r ".title" "$filename")
if [ -z "$title" ]; then
    exit 1
fi

version=$(jq -r ".version" "$filename")
if [ -z "$version" ]; then
    exit 1
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

if [ ! -d "debian" ]; then
    mkdir -p debian
    mkdir -p debian/opt/tros/lib
    mkdir -p debian/opt/tros/share
    mkdir -p debian/opt/tros/lib
    mkdir -p debian/opt/tros/include
else
    sudo rm -rf debian
    mkdir -p debian
    mkdir -p debian/opt/tros/lib
    mkdir -p debian/opt/tros/share
    mkdir -p debian/opt/tros/lib
    mkdir -p debian/opt/tros/include
fi

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

robotchain package