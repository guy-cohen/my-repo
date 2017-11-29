FROM dockerv2.jfrog.info/openjdk:8u102-jdk
MAINTAINER eldada@jfrog.com
# Copy the artifactory zip and entrypoint files
COPY standalone.zip /opt/jfrog/
COPY entrypoint-artifactory.sh /
# Set vars
ENV ARTIFACTORY_USER_NAME=artifactory
ENV ARTIFACTORY_USER_ID=1030
ENV ARTIFACTORY_HOME /opt/jfrog/artifactory
ENV ARTIFACTORY_DATA /var${ARTIFACTORY_HOME}
ENV RECOMMENDED_MAX_OPEN_FILES 32000
ENV MIN_MAX_OPEN_FILES 10000
ENV RECOMMENDED_MAX_OPEN_PROCESSES 1024
# Install gosu (this is from https://github.com/tianon/gosu)
ENV GOSU_VERSION 1.9
RUN set -x && \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true
# Update the OS (exclude openjdk-8 packages)
RUN apt-get update && \
    apt-mark hold openjdk-8-* && \
    apt-get upgrade -y
# Extract artifactory zip and create needed directories and softlinks
RUN unzip -q /opt/jfrog/standalone.zip -d /opt/jfrog/ && \
    mv ${ARTIFACTORY_HOME}*/ ${ARTIFACTORY_HOME}/ && \
    rm -f /opt/jfrog/standalone.zip && \
    mv ${ARTIFACTORY_HOME}/etc ${ARTIFACTORY_HOME}/etc.orig/ && \
    rm -rf ${ARTIFACTORY_HOME}/logs && \
    ln -s ${ARTIFACTORY_DATA}/etc ${ARTIFACTORY_HOME}/etc && \
    ln -s ${ARTIFACTORY_DATA}/data ${ARTIFACTORY_HOME}/data && \
    ln -s ${ARTIFACTORY_DATA}/logs ${ARTIFACTORY_HOME}/logs && \
    ln -s ${ARTIFACTORY_DATA}/backup ${ARTIFACTORY_HOME}/backup && \
    ln -s ${ARTIFACTORY_DATA}/access ${ARTIFACTORY_HOME}/access && \
    chmod +x /entrypoint-artifactory.sh
# Default mounts. Should be passed in `docker run` or in docker-compose
VOLUME ${ARTIFACTORY_DATA}
# Expose Tomcat's port
EXPOSE 8081
# Start the simple standalone mode of Artifactory
ENTRYPOINT /entrypoint-artifactory.sh
