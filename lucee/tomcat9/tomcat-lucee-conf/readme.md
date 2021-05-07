## Lucee Tomcat Configuration Customizations 

This folder contains the modified Tomcat configuration files required for Lucee.

There are only a few changes from the default Tomcat config, you can diff these folders against and standard Tomcat distribution to see what has been changed.
 
- adding in a few jars (lucee, mod-valve etc)
- adding in the CFML servlet (which basically installs lucee!)
- using placeholders for variables configured by the installer

### Setup and and configure Tomcat 9 for the installer

- Download and extract the latest Tomcat 9 Windows dist into `lucee-installer\lucee\tomcat9\tomcat` (windows distribution is needed, for the windows service control.exe)
- Delete all the default content in the webapps directory `lucee-installer\lucee\tomcat9\tomcat\webapps`
- Copy all the files from `lucee-installer\lucee\tomcat9\tomcat-lucee-conf` into `lucee-installer\lucee\tomcat9\tomcat` 
