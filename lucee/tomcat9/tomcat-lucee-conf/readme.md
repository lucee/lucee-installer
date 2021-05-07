This folder contains the modified Tomcat configuration files required for Lucee.

There are only a few changes from the default Tomcat config
 
- adding in a few jars (lucee, mod-valve etc)
- adding in the CFML servlet (which basically installs lucee!)
- using placeholders for variables configured by the installer

All these changes can be found in the lucee-installer\lucee\tomcat9\tomcat-lucee-conf directory (diff against the tomcat dist to see what changed) 

To update Tomcat 9

- Download and extract the latest Tomcat 9 Windows dist into [lucee-installer\lucee\tomcat9\tomcat ] (windows dist is needed the windows service control.exe)
- Delete all the default content in the webapps directory [ lucee-installer\lucee\tomcat9\tomcat\webapps ]
- Copy the contents of the [ lucee-installer\lucee\tomcat9\tomcat-lucee-conf ] into [ lucee-installer\lucee\tomcat9\tomcat ]
 