# Lucee Installer #

BitRock Installer XML config and files for creating the Lucee installers for Windows and Linux.

Bitrock has provided LAS with an Enterprise license for InstallBuilder, it's not in source source control

Forked from the great work by Vivotech, https://github.com/viviotech/lucee-installer, LAS is now managing the Lucee Installer Releases

### Build Preparation ###

None of the main binaries are checked into source control, the following manual steps are required

- The Lucee loader jar goes into the `/jars` folder, i.e. (https://cdn.lucee.org/lucee-5.3.7.48.jar)
- Download and extract the Tomcat 9 Windows distribution (it includes a few extra files required for the windows install) into the `lucee\tomcat9\tomcat` folder (https://mirror.checkdomain.de/apache/tomcat/tomcat-9/v9.0.45/bin/apache-tomcat-9.0.45-windows-x64.zip)
- Copy the customised `lucee\tomcat9\tomcat-lucee-conf` Lucee Tomcat configuration files over the extracted Tomcat distribution files
- Download Windows and Linux 64-bit JREs from (https://adoptopenjdk.net/releases.html) and extract them in the `/jre` folders (delete the manual directory from the linux JRE)
- Download and install the InstallBuilder Enterprise Edition (https://installbuilder.com/) 

### Build ###

Simply open the [lucee/lucee.xml](lucee/lucee.xml) file in InstallBuilder

### Support ###

Please first post any support questions to the Lucee Dev Forum (https://dev.lucee.org/)

Issues are in Lucee's Issue Tracker (https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20%22installer%22)
