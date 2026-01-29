#!/usr/bin/bash
cd `dirname $0`

sudo cp 99-tangnano9k.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
