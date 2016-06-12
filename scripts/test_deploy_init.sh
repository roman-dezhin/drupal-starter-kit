#!/bin/sh
# Deploy init script.
# ZenCI platform.

# Let's speedup database by moving it to /dev/shm
sudo /sbin/service mysql stop
sudo cp -ax /var/lib/mysql /dev/shm/mysql
sudo mv /var/lib/mysql /var/lib/mysql.old
sudo ln -s /dev/shm/mysql /var/lib/mysql
sudo /sbin/service mysql start

#prepare DOCROOT
mkdir $DOCROOT

#install drupal
sh $ZENCI_DEPLOY_DIR/scripts/test_drupal_install.sh

echo "Full site path: $DOCROOT"

# Go to domain directory.
cd $DOCROOT

echo "Linking modules from $ZENCI_DEPLOY_DIR"

mkdir -p $DOCROOT/sites/all/modules/contrib
mkdir -p $DOCROOT/sites/all/themes/contrib
mkdir -p $DOCROOT/sites/all/libraries

cd $DOCROOT/sites/all/modules
ln -s $ZENCI_DEPLOY_DIR/modules ./custom

cd $DOCROOT/sites/all/themes
ln -s $ZENCI_DEPLOY_DIR/themes ./custom

cd $DOCROOT/sites/all/libraries
ln -s $ZENCI_DEPLOY_DIR/libraries ./custom


echo "Enable Modules & themes"
cd $DOCROOT

for project in `cat $ZENCI_DEPLOY_DIR/settings/enable.list`; do
  drush -y en $project
done

if [ "$DEFAULT_THEME" != "" ]; then
  echo "Set default theme"
  drush -y en $DEFAULT_THEME
  drush vset theme_default $DEFAULT_THEME
fi

if [ "$ENABLE_DEVEL" != "" ]; then
  drush dl devel
  drush -y en devel devel_generate
  drush generate-content 100
  drush generate-users 100
fi