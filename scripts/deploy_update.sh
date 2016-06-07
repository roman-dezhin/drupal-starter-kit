#!/bin/sh

STATUSFILE="$DOCROOT/.deploy.status"
UPDATEDIR="$ZENCI_DEPLOY_DIR/settings/update/"

echo "Full site path: $DOCROOT"

# Go to domain directory.
cd $DOCROOT

# create file if doesnot exists, overwise just change a modification time.
touch $STATUSFILE

for file in `ls $UPDATEDIR|grep sh$|grep -vf $STATUSFILE`;do
  echo "Processing $file"
  sh $UPDATEDIR/$file
  echo "$file" >> $STATUSFILE
done

# clean cache
drush cc all
