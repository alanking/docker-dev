#!/bin/bash
set -e

## run npm install
cd /tmp/irods-cloud-browser/irods-cloud-frontend
npm install --unsafe-perm 
npm install --global gulp-cli

##Switch to correct branch of cloudrbowser
#cd /tmp/irods-cloud-browser
#git checkout rit-cloud-browser

     
## run gulp builds 
gulp backend-clean
gulp backend-build
gulp gen-war


##move build war to tomcat webapps directory
cp /tmp/irods-cloud-browser/build/irods-cloud-backend.war /var/lib/tomcat8/webapps/

# Start Tomcat8 service
/var/lib/tomcat8/bin/startup.sh

# Force start of apache2 server
rm -f /var/run/apache2/apache2.pid
service apache2 start

# this script must end with a persistent foreground process
tail -f /var/lib/tomcat8/logs/catalina.out

