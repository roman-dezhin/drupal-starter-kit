#!/bin/sh
# Install drupal based on ZenCI provided ENV Variables.

echo "Install script started"

CORE='drupal-7.x'

echo "Full site path: $DOCROOT"
echo "Site core: $CORE"

cd $DOCROOT

echo "Download DRUPAL."

drush dl $CORE --drupal-project-rename="drupal" --package-handler=git_drupalorg
rsync -a $DOCROOT/drupal/ $DOCROOT
rm -rf drupal


echo "Installing $CORE to " . $DOCROOT

drush site-install standard -y --root=$DOCROOT --account-mail=$ACCOUNT_MAIL --account-name=$ACCOUNT_USER --account-pass="$ACCOUNT_PASS" --site-mail=$SITE_MAIL --site-name="$SITE_NAME" --uri=http://$DOMAIN_NAME --db-url=mysql://$DATABASE_USER:$DATABASE_PASS@localhost/$DATABASE_NAME

echo "user: $ACCOUNT_USER pass: $ACCOUNT_PASS"
