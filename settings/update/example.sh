#!/bin/sh

echo "Disable devel"
#remove devel module

drush -y dis devel
drush -y pm-uninstall devel
