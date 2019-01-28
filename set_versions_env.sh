#!/usr/bin/env bash

####################################################################################
### Use this file to specify desired versions for various application containers ###
####################################################################################

# iRODS and iRES
ENV_IRODS_VERSION=4.2.4     # Note: also used in davrods container
ENV_IRODS_EXT_CLANG_VERSION=3.8-0
ENV_IRODS_EXT_CLANG_RUNTIME_VERSION=3.8-0
ENV_CMAKE_VERSION=3.12
ENV_CMAKE_LONG_VERSION=3.12.0

# iRODS-frontend
ENV_IRODS_REST_VERSION=4.1.10.0-RC1
ENV_CLOUDBROWSER_VERSION=1.1.1-RELEASE-MUMC

# DavRODS
ENV_DAVRODS_VERSION=4.2.4_1.4.2

# Pacman
ENV_XDEBUG_VERSION=2.6.1
ENV_DRUPAL_VERSION=7.59
ENV_DRUPAL_VERSION_MD5=7e09c6b177345a81439fe0aa9a2d15fc
ENV_ISLANDORA_VERSION=1.11

# MirthConnect
ENV_MIRTH_CONNECT_VERSION=3.7.0.b2399

# For containers that use docker images
ENV_MYSQL_VERSION=5.6
ENV_POSTGRES_VERSION=9.4

# Other (used in various containers)
ENV_DOCKERIZE_VERSION=v0.2.0
ENV_FILEBEAT_VERSION=5.2.0





# Export all vars to environment (to be passed to docker-compose)
export ENV_IRODS_VERSION
export ENV_IRODS_EXT_CLANG_VERSION
export ENV_IRODS_EXT_CLANG_RUNTIME_VERSION
export ENV_CMAKE_VERSION
export ENV_CMAKE_LONG_VERSION
export ENV_IRODS_REST_VERSION
export ENV_CLOUDBROWSER_VERSION
export ENV_DAVRODS_VERSION
export ENV_XDEBUG_VERSION
export ENV_DRUPAL_VERSION
export ENV_DRUPAL_VERSION_MD5
export ENV_ISLANDORA_VERSION
export ENV_MIRTH_CONNECT_VERSION
export ENV_MYSQL_VERSION
export ENV_POSTGRES_VERSION
export ENV_DOCKERIZE_VERSION
export ENV_FILEBEAT_VERSION