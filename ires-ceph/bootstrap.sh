#!/bin/bash

set -e

source /etc/secrets

# Update RIT rules
# FYI: This step (and make of the microservices) rely on sequential starts of the ires-containers. If those containers
# start simultaneously, the make steps fail because they are accessing the same files at the same time.
# Now solved by letting ires_centos wait for ires:1248 in Dockerize
cd /rules && make install

# Remove previous build dir (if exists)
if [ -d "/microservices/build" ]; then
  rm -fr /microservices/build
fi

# Update RIT microservices
mkdir -p /microservices/build && cd /microservices/build && cmake .. && make && make install

# Update RIT helpers
cp /helpers/* /var/lib/irods/msiExecCmd_bin/.

# Check if this is a first run of this container
if [[ ! -e /var/run/irods_installed ]]; then

    if [ -n "$RODS_PASSWORD" ]; then
        echo "Setting irods password"
        sed -i "16s/.*/$RODS_PASSWORD/" /etc/irods/setup_responses
    fi

    # set up iRODS
    python /var/lib/irods/scripts/setup_irods.py < /etc/irods/setup_responses

    # Add the ruleset-rit to server config
    /opt/irods/prepend_ruleset.py /etc/irods/server_config.json rit-misc
    /opt/irods/prepend_ruleset.py /etc/irods/server_config.json rit-ingest
    /opt/irods/prepend_ruleset.py /etc/irods/server_config.json rit-projects
    /opt/irods/prepend_ruleset.py /etc/irods/server_config.json rit-projectCollection

    # Add config variable to iRODS
    /opt/irods/add_env_var.py /etc/irods/server_config.json MIRTH_METADATA_CHANNEL ${MIRTH_METADATA_CHANNEL}
    /opt/irods/add_env_var.py /etc/irods/server_config.json MIRTH_VALIDATION_CHANNEL ${MIRTH_VALIDATION_CHANNEL}
    /opt/irods/add_env_var.py /etc/irods/server_config.json IRODS_INGEST_REMOVE_DELAY ${IRODS_INGEST_REMOVE_DELAY}

    # Dirty temp.password workaround
    sed -i 's/\"default_temporary_password_lifetime_in_seconds\"\:\ 120\,/\"default_temporary_password_lifetime_in_seconds\"\:\ 86400\,/' /etc/irods/server_config.json

    su - irods -c "/opt/irods/bootstrap_irods.sh"

    touch /var/run/irods_installed

else
    service irods start
fi

# Force start of Metalnx RMD
service rmd restart

#logstash
/etc/init.d/filebeat start

# Install iRODS librados plugin
echo "compiling iRODS rados plugin"
cd /irods_resource_plugin_rados && cmake -DCMAKE_INSTALL_PREFIX=/ . && make && make install

# Templating irados config file
touch /etc/irods/irados.config && chown irods /etc/irods/irados.config && chmod 600 /etc/irods/irados.config
echo "[global]
    mon host = ${CEPHGLMONHOST}
    
[${CEPHGLUSER}]
    key = ${CEPHGLKEY}" > /etc/irods/irados.config

# Add rados resource
su - irods -c "iadmin mkresc radosResc irados ires-ceph:/tmp \"ceph|irods-dev|client.irods-dev\" "


# Install iRODS librados plugin
echo "compiling iRODS rados plugin"
cd /irods_resource_plugin_s3 && cmake . && make package
dpkg -i irods-resource-plugin-s3_2.5.0~bionic_amd64.deb

# Templating irados config file
touch /var/lib/irods/s3.keypair && chown irods /var/lib/irods/s3.keypair && chmod 600 /var/lib/irods/s3.keypair
echo ${CEPHGLS3ACCESSKEY} > /var/lib/irods/s3.keypair
echo ${CEPHGLS3SECRETKEY} >> /var/lib/irods/s3.keypair

# Add S3 resource
su - irods -c "iadmin mkresc s3resc s3 `hostname`:/irods-bucket/irods/Vault \"S3_DEFAULT_HOSTNAME=cephmongl01.unimaas.nl;S3_AUTH_FILE=/var/lib/irods/s3.keypair;S3_REGIONNAME=irods-dev;S3_RETRY_COUNT=1;S3_WAIT_TIME_SEC=3;S3_PROTO=HTTPS;ARCHIVE_NAMING_POLICY=consistent;HOST_MODE=cacheless_attached\""

# this script must end with a persistent foreground process
tail -F /var/lib/irods/log/rodsLog.*
