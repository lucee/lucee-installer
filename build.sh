#!/bin/bash
set -eu

wget https://cdn.lucee.org/lucee-${LUCEE_VERSION}.jar
mv lucee-${LUCEE_VERSION}.jar lucee/lucee/lib/

wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.78/bin/apache-tomcat-9.0.78.tar.gz
cd lucee/tomcat9/
tar zxf ../../apache-tomcat-9.0.78.tar.gz
cd ../..

rm apache-tomcat-9.0.78.tar.gz

mv lucee/tomcat9/apache-tomcat-9.0.78  lucee/tomcat9/tomcat
rm -rf lucee/tomcat9/tomcat/webapps

cp -ar lucee/tomcat9/tomcat-lucee-conf/ lucee/tomcat9/tomcat/

wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.19%2B7/OpenJDK11U-jre_x64_linux_hotspot_11.0.19_7.tar.gz
tar zxf OpenJDK11U-jre_x64_linux_hotspot_11.0.19_7.tar.gz 
mv jdk-11.0.19+7-jre/* jre/jre64-lin/jre/
rmdir jdk-11.0.19+7-jre

wget https://releases.installbuilder.com/installbuilder/installbuilder-enterprise-23.4.0-linux-installer.run
chmod a+x ./installbuilder-enterprise-23.4.0-linux-installer.run
./installbuilder-enterprise-23.4.0-linux-installer.run --prefix /tmp/ib --mode unattended

bin/builder quickbuild /path/to/project.xml