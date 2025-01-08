FROM ubuntu:24.04

ARG FTP_USER=proftpd_user
ARG FTP_GROUP=nogroup
ARG FTP_SSL_CERTS_DIR=/etc/ssl/ftp
ARG FTP_USERS_DIR=/var/ftp/users

ENV DEBIAN_FRONTEND=noninteractive \
    FTP_DEBUG_LEVEL=0 \
    FTP_LOG_LEVEL=warn \
    FTP_MASQUERADE_ADDRESS= \
    FTP_PASSIVE_PORT_RANGE_START=60000 \
    FTP_PASSIVE_PORT_RANGE_END=60100 \
    FTP_SQL_USERS_TABLE=ftpusers \
    FTP_TLS_CERTIFICATE_FILE=/etc/ssl/ftp/proftpd.crt \
    FTP_TLS_CERTIFICATE_KEY_FILE=/etc/ssl/ftp/proftpd.key \
    FTP_TLS_REQUIRED=off \
    FTP_TLS_WAIT_FOR_CERTIFICATE=false \
    FTP_TLS_WAIT_TIMEOUT=60 \
    FTP_USER=${FTP_USER} \
    FTP_GROUP=${FTP_GROUP} \
    FTP_SSL_CERTS_DIR=${FTP_SSL_CERTS_DIR} \
    FTP_USERS_DIR=${FTP_USERS_DIR} \
    MYSQL_DATABASE=ftpdb \
    MYSQL_HOST=mysql \
    MYSQL_PASSWORD=ftppassword \
    MYSQL_PORT=3306 \
    MYSQL_USER=ftpuser

# Update and install required packages
RUN apt-get update && apt-get install -y \
    proftpd-basic \
    proftpd-mod-crypto \
    proftpd-mod-mysql \
    openssl \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY proftpd.conf /etc/proftpd/proftpd.conf

# Create a user for ProFTPD
RUN useradd -r -s /bin/false ${FTP_USER}

# Create a directory for FTP and set permissions
RUN mkdir -p /var/ftp/ && \
    touch /var/ftp/ban.tab && \
    chown -R ${FTP_USER}:${FTP_GROUP} /var/ftp && \
    mkdir -p ${FTP_SSL_CERTS_DIR}

# Create a base directory for user homes
RUN mkdir -p ${FTP_USERS_DIR} && \
    chown ${FTP_USER}:${FTP_GROUP} ${FTP_USERS_DIR} && \
    chmod 755 ${FTP_USERS_DIR}

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# Expose FTP ports (FTP, FTPS, Passive Ports)
EXPOSE 21 990 60000-60100

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD nc -z localhost 21 || exit 1

# Start ProFTPD
CMD ["proftpd", "--nodaemon"]