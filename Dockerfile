FROM centos:centos7

# This is a branch of madhead/docker-oracle-xe updated to use CentOS 7 and Oracle XE 18c
# https://github.com/madhead/docker-oracle-xe

# Build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="centos-oracle-xe-18c" \
      org.label-schema.description="Docker image for Oracle XE 18c based on CentOS 7" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url="https://www.github.com/jacktar283/centos-oracle-xe-18c" \
      org.label-schema.version=${VERSION} \
      org.label-schema.schema-version="1.0"


# These RPMS should be downloaded from Oracle website and copied
# into our local rpm directory
ENV ORACLE_PREINST_RPM=oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm \
    ORACLE_RPM=oracle-database-xe-18c-1.0-1.x86_64.rpm \
    ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE \
    ORACLE_USER=oracle \
    ORACLE_GROUP=oinstall \
    INIT_PASS=oracle \
    PATH=$ORACLE_HOME/bin:$PATH \
    ORACLE_SID=XE \
    ORACLE_DOCKER_INSTALL=true \
    DBFILE_DEST=/oracle-data

# Pre-requirements
RUN mkdir -p /run/lock/subsys $DBFILE_DEST

RUN yum install -y libaio bc initscripts net-tools; \
    yum clean all

# Create fake 'free' command to spoof swap space
RUN mv /usr/bin/free /usr/bin/free.orig
COPY assets/fake-swap.sh /tmp/fake-swap.sh
RUN /bin/sh /tmp/fake-swap.sh && rm /tmp/fake-swap.sh

# Perform Oracle XE preinstallation
# Needs to be done prior to main installation
# This does install some limits for memlock that cause problems in our containers...
# limits are installed under /etc/security/limits.d/oracle-database-preinstall-18c.conf
COPY rpm/$ORACLE_PREINST_RPM /tmp/
RUN yum localinstall -y /tmp/$ORACLE_PREINST_RPM && \
    rm -rf /tmp/$ORACLE_PREINST_RPM && \
    sed -i -e "s/\(oracle.*memlock.*\)$/# \1/" /etc/security/limits.d/oracle-database-preinstall-18c.conf

# Install Oracle XE
COPY rpm/$ORACLE_RPM /tmp/
RUN yum localinstall -y /tmp/$ORACLE_RPM && \
    rm -rf /tmp/$ORACLE_RPM

# Restore 'free' command
RUN mv /usr/bin/free.orig /usr/bin/free

# Configure instance
RUN mkdir -p $ORACLE_HOME/config/
ADD config/init.ora config/initXETemp.ora $ORACLE_HOME/config/
RUN chown -R $ORACLE_USER:dba $ORACLE_HOME/config && \
    chmod -R 755 $ORACLE_HOME/config && \
    ( echo "$INIT_PASS"; echo "$INIT_PASS"; ) |/etc/init.d/oracle-xe-18c configure

VOLUME $DBFILE_DEST
# Run script
COPY config/start.sh /
#CMD /start.sh
CMD bash

EXPOSE 1521
EXPOSE 8080
