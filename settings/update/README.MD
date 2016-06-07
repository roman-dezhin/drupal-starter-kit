# Update scripts
Place scripts to run some tasks once script deployed on server.

**WARNING** This scripts run only once when first time deployed on server.

see more details in update.sh script

Example

```bash
#!/bin/sh

#remove acl module

drush -y dis acl
drush -y pm-uninstall acl
```

