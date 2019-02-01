FROM tomcat:7-jre8-alpine
MAINTAINER John Flavin <jflavin@wustl.edu>

ARG XNAT_VER
ARG XNAT_ROOT=/data/xnat
ARG XNAT_HOME=/data/xnat/home
ARG XNAT_DATASOURCE_DRIVER=org.postgresql.Driver
ARG XNAT_DATASOURCE_URL=jdbc:postgresql://xnat-db/xnat
ARG XNAT_DATASOURCE_USERNAME=xnat
ARG XNAT_DATASOURCE_PASSWORD=xnat
ARG XNAT_HIBERNATE_DIALECT=org.hibernate.dialect.PostgreSQL9Dialect
ARG TOMCAT_XNAT_FOLDER=ROOT
ARG SMTP_ENABLED=false
ARG SMTP_HOSTNAME=fake.fake
ARG SMTP_PORT
ARG AMTP_AUTH
ARG SMTP_USERNAME
ARG SMTP_PASSWORD

ADD make-xnat-config.sh /usr/local/bin/make-xnat-config.sh
ADD wait-for-postgres.sh /usr/local/bin/wait-for-postgres.sh

RUN addgroup -g 900 xnat && adduser -D -u 900 -G xnat xnat

RUN apk add --no-cache \
        postgresql-client \
        wget

RUN rm -rf $CATALINA_HOME/webapps/*

RUN mkdir -p \
        $CATALINA_HOME/webapps/${TOMCAT_XNAT_FOLDER} \
        ${XNAT_HOME}/config \
        ${XNAT_HOME}/logs \
        ${XNAT_HOME}/plugins \
        ${XNAT_HOME}/work \
        ${XNAT_ROOT}/archive \
        ${XNAT_ROOT}/build \
        ${XNAT_ROOT}/cache \
        ${XNAT_ROOT}/ftp \
        ${XNAT_ROOT}/pipeline \
        ${XNAT_ROOT}/prearchive && \
    /usr/local/bin/make-xnat-config.sh && \
    cd $CATALINA_HOME/webapps/ && \
    wget https://api.bitbucket.org/2.0/repositories/xnatdev/xnat-web/downloads/xnat-web-${XNAT_VER}.war && \
    cd ${TOMCAT_XNAT_FOLDER} && \
    unzip -o ../xnat-web-${XNAT_VER}.war && \
    rm -f ../xnat-web-${XNAT_VER}.war

RUN chown -R 900:900 ${XNAT_ROOT}

RUN chown -R 900:900 ${CATALINA_HOME}

EXPOSE 8080

# Gebruik {} bij assignment!!
ENV XNAT_HOME=${XNAT_HOME} \
    XNAT_DATASOURCE_USERNAME=${XNAT_DATASOURCE_USERNAME} \
    XNAT_ROOT=${XNAT_ROOT} \
	XNAT_HOME=${XNAT_HOME} \
	XNAT_DATASOURCE_DRIVER={XNAT_DATASOURCE_DRIVER} \
	XNAT_DATASOURCE_URL={XNAT_DATASOURCE_URL} \
	XNAT_DATASOURCE_USERNAME={XNAT_DATASOURCE_USERNAME} \
	XNAT_DATASOURCE_PASSWORD={XNAT_DATASOURCE_PASSWORD} \
	XNAT_HIBERNATE_DIALECT={XNAT_HIBERNATE_DIALECT} \
	TOMCAT_XNAT_FOLDER={TOMCAT_XNAT_FOLDER} \
	SMTP_ENABLED={SMTP_ENABLED} \
	SMTP_HOSTNAME={SMTP_HOSTNAME}
    

CMD ["wait-for-postgres.sh", "/usr/local/tomcat/bin/catalina.sh", "run"]
