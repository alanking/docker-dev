#!/usr/bin/env bash

set -e

############
## Resources

# Place a rootResc (passthru) in front of the default resource as described here https://docs.irods.org/4.1.8/manual/best_practices/
# This ensures that you can replace demoResc in the future without respecifying every client's default resource.
# The default resource for the zone (= rootResc) is included in a rit-policy (acSetRescSchemeForCreate)
iadmin mkresc rootResc passthru
iadmin addchildtoresc rootResc demoResc

# Create resources and make them members of the (composable) replication resource.
iadmin mkresc replRescUM01 replication
iadmin mkresc UM-hnas-4k unixfilesystem ${IRODS_RESOURCE_HOST_DEB}:/mnt/UM-hnas-4k
iadmin mkresc UM-hnas-4k-repl unixfilesystem ${IRODS_RESOURCE_HOST_DEB}:/mnt/UM-hnas-4k-repl
iadmin addchildtoresc replRescUM01 UM-hnas-4k
iadmin addchildtoresc replRescUM01 UM-hnas-4k-repl

iadmin mkresc replRescAZM01 replication
iadmin mkresc AZM-storage unixfilesystem ${IRODS_RESOURCE_HOST_RPM}:/mnt/AZM-storage
iadmin mkresc AZM-storage-repl unixfilesystem ${IRODS_RESOURCE_HOST_RPM}:/mnt/AZM-storage-repl
iadmin addchildtoresc replRescAZM01 AZM-storage
iadmin addchildtoresc replRescAZM01 AZM-storage-repl

##############
## Collections
imkdir -p /nlmumc/ingest/zones
imkdir -p /nlmumc/ingest/shares/rawdata
imkdir -p /nlmumc/projects

########
## Users
users="p.vanschayck m.coonen d.theunissen p.suppers rbg.ravelli g.tria p.ahles delnoy r.niesten"
domain="maastrichtuniversity.nl"

for user in $users; do
    iadmin mkuser "${user}@${domain}" rodsuser
    iadmin moduser "${user}@${domain}" password foobar
done

serviceUsers="service-dropzones service-mdl service-dwh service-pid"

for user in $serviceUsers; do
    iadmin mkuser "${user}" rodsuser
    iadmin moduser "${user}" password foobar
done


#########
## Groups
nanoscopy="p.vanschayck g.tria rbg.ravelli"

iadmin mkgroup nanoscopy-l
for user in $nanoscopy; do
    iadmin atg nanoscopy-l "${user}@${domain}"
done

rit="p.vanschayck m.coonen d.theunissen p.suppers delnoy r.niesten"

iadmin mkgroup rit-l
for user in $rit; do
    iadmin atg rit-l "${user}@${domain}"
done

##############
## Permissions

# Make sure that all users (=members of group public) can browse to directories for which they have rights
ichmod read public /nlmumc
ichmod read public /nlmumc/projects

# Give all relevant groups write-access to the ingest-zones parent-collection
# This is needed because users need sufficient permissions to delete dropzone-collections by the msiRmColl operation in 'ingestNestedDelay2.r'
# See RITDEV-219
ichmod write nanoscopy-l /nlmumc/ingest/zones
ichmod write rit-l /nlmumc/ingest/zones

###########
## Projects and project permissions

for i in {01..2}; do
    project=$(irule -F /rules/projects/createProject.r)
    # AVU's for collections
    imeta set -C /nlmumc/projects/${project} ingestResource ${IRODS_RESOURCE_HOST_DEB}Resource
    imeta set -C /nlmumc/projects/${project} resource replRescUM01
    imeta set -C /nlmumc/projects/${project} title "`fortune | head -n 1`"

    # Contributor access for nanoscopy
    ichmod -r write nanoscopy-l /nlmumc/projects/${project}
    # Manage access for Paul
    ichmod -r own "p.vanschayck@${domain}" /nlmumc/projects/${project}
done

for i in {01..3}; do
    project=$(irule -F /rules/projects/createProject.r)
    # AVU's for collections
    imeta set -C /nlmumc/projects/${project} ingestResource ${IRODS_RESOURCE_HOST_DEB}Resource
    imeta set -C /nlmumc/projects/${project} resource replRescUM01
    imeta set -C /nlmumc/projects/${project} title "`fortune | head -n 1`"

    # Contributor access for RIT
    ichmod -r write rit-l /nlmumc/projects/${project}
    # Manage access for suppers
    ichmod -r own "p.suppers@${domain}" /nlmumc/projects/${project}
done

for i in {01..3}; do
    project=$(irule -F /rules/projects/createProject.r)
    # AVU's for collections
    imeta set -C /nlmumc/projects/${project} ingestResource ${IRODS_RESOURCE_HOST_DEB}Resource
    imeta set -C /nlmumc/projects/${project} resource replRescUM01
    imeta set -C /nlmumc/projects/${project} title "`fortune | head -n 1`"

    # Read access for rit
    ichmod -r read rit-l /nlmumc/projects/${project}

    # Manage access for Daniel
    ichmod -r own "d.theunissen@${domain}" /nlmumc/projects/${project}
done

for i in {01..4}; do
    project=$(irule -F /rules/projects/createProject.r)
    # AVU's for collections
    imeta set -C /nlmumc/projects/${project} ingestResource ${IRODS_RESOURCE_HOST_RPM}Resource
    imeta set -C /nlmumc/projects/${project} resource replRescAZM01
    imeta set -C /nlmumc/projects/${project} title "`fortune | head -n 1`"

    # Contributor access for RIT
    ichmod -r write rit-l /nlmumc/projects/${project}
    # Manage access for suppers
    ichmod -r own "p.suppers@${domain}" /nlmumc/projects/${project}
done

# service-dwh
ichmod -r read service-dwh /nlmumc/projects

# service-pid
ichmod -r write service-pid /nlmumc/projects

##########
## Special

# Create an initial collection folder for MDL data
imkdir /nlmumc/projects/P000000010/C000000001
ichmod -r write "service-mdl" /nlmumc/projects/P000000010

# Create an initial collection folder for HVC data
imkdir /nlmumc/projects/P000000011/C000000001
ichmod -r write "service-mdl" /nlmumc/projects/P000000011
