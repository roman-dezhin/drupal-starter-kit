#!/bin/sh

#prepare database access
mysqladmin -uroot create $DATABASE_NAME
mysql -u root mysql -e "CREATE USER '"$DATABASE_USER"'@'localhost';"
mysql -u root mysql -e "GRANT ALL ON $DATABASE_NAME.* TO '"$DATABASE_USER"'@'localhost' IDENTIFIED BY '"$DATABASE_PASS"';"

#prepare DOCROOT
mkdir $DOCROOT

#prepare apache config and restart it.
cat $HOME/conf.d/template|sed 's/{$DOMAIN}/'$DOMAIN'/g' > $HOME/conf.d/$DOMAIN.conf
sudo apachectl restart

#install drupal
sh $ZENCI_DEPLOY_DIR/scripts/drupal_install.sh

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
