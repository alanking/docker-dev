FROM ubuntu:16.04

# Load build arguments from environment
ARG ENV_IRODS_VERSION
ARG ENV_IRODS_EXT_CLANG_VERSION
ARG ENV_IRODS_EXT_CLANG_RUNTIME_VERSION
ARG ENV_IRODS_EXT_CMAKE_VERSION
ARG ENV_FILEBEAT_VERSION

# Use apt-get NL mirrors
#RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1nl.\2/" /etc/apt/sources.list && apt-get update

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-transport-https \
    wget \
    unixodbc \
    super \
    odbc-postgresql \
    postgresql-client \
    libfuse2 \
    libjson-perl \
    librabbitmq-dev \
    libxml2 \
    python \
    python-psutil \
    python-requests \
    python-jsonschema \
    python-ldap \
    sudo \
    lsof \
    fortune-mod \
    nano \
    # packages required for building ruleset and microservices {{
    libssl-dev \
    libcurl4-openssl-dev \
    g++ \
    make \
    lsb-release
    # }} end

ENV IRODS_VERSION ${ENV_IRODS_VERSION}

# install iRODS
RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | sudo apt-key add - \
    && echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/renci-irods.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    irods-runtime=${IRODS_VERSION} \
    irods-icommands=${IRODS_VERSION} \
    irods-server=${IRODS_VERSION} \
    irods-database-plugin-postgres=${IRODS_VERSION} \
    irods-dev=${IRODS_VERSION} \
    # packages required for building microservices
    irods-externals-cmake${ENV_IRODS_EXT_CMAKE_VERSION} \
    irods-externals-clang-runtime${ENV_IRODS_EXT_CLANG_RUNTIME_VERSION} \
    irods-externals-clang${ENV_IRODS_EXT_CLANG_VERSION}

RUN mkdir /opt/irods

ADD ./setup_responses /etc/irods/setup_responses
ADD ./setupdb.sh /opt/irods/setupdb.sh
ADD ./config.sh /opt/irods/config.sh
ADD ./bootstrap.sh /opt/irods/bootstrap.sh
ADD ./bootstrap_irods.sh /opt/irods/bootstrap_irods.sh
RUN chmod a+x /opt/irods/*

EXPOSE 1248 1247

###############################################################################

ENTRYPOINT [ "/opt/irods/bootstrap.sh" ]
