# drupal-starter-kit
Repository contain integration scripts to start using deploy via ZenCI for DrupalCMS website

It has next structure
-------
```yaml
modules					#put your own custom modules here
libraries					#put your own custom libraries here
scripts					#deploy related scripts
  deploy_init.sh		#init script. It will be executed only if {deploy_dir} is empty
  deploy_update.sh		#after script. It will be executed after each push to repository
  drupal_install.sh		#download via drush Drupal and install it
settings				#meta data for deploy
  update				#place to put your scripts to run once when created
    example.sh			#example script
  enable.enable			#list of projects to enable
themes					#put your own custom themes here
```
## Directory structure after deploy.

**deploy_init.sh** will create directory structure in $HOME/github 

```yaml
github:
  YOURNAME:
    drupal-startup-kit:	#your repository get cloned here
      modules: 				# your own modules
      themes: 				# your own themes
      libraries: 				# your own libraries
```

Your **DOCROOT** will have full drupal code structure with next extra:

- **sites/all/modules**:

```textile
contrib 
custom -> ~/github/YOURNAME/drupal-starter-kit/master/modules
```

- **sites/all/themes**:

```textile
contrib 
custom -> ~/github/YOURNAME/drupal-starter-kit/master/themes
```

- **sites/all/libraries**:

```textile
contrib 
custom -> ~/github/YOURNAME/drupal-starter-kit/master/libraries
```

Credits
-------

- [DrupalCMS](https://drupal.org)
- [HowTO](http://docs.zen.ci/advanced-start/advanced-deploy-drupal)


License
-------

This project is GPL v2 software. See the LICENSE.txt file in this directory for
complete text.
