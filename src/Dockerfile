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
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY proftpd.conf /etc/proftpd/proftpd.conf

# Create a user for ProFTPD
RUN useradd -r -s /bin/false ${FTP_USER}

# Create a directory for FTP and set permissions
RUN mkdir -p /var/ftp/ && \
    touch /var/ftp/ban.tab && \
    chown -R ${FTP_USER}:${FTP_GROUP} /var/ftp

# Generate self-signed SSL certificate
RUN mkdir -p ${FTP_SSL_CERTS_DIR} && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ${FTP_TLS_CERTIFICATE_KEY_FILE} \
    -out ${FTP_TLS_CERTIFICATE_FILE} \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" && \
    chmod 600 ${FTP_TLS_CERTIFICATE_KEY_FILE} && \
    chown -R ${FTP_USER}:${FTP_GROUP} ${FTP_SSL_CERTS_DIR}

# Create a base directory for user homes
RUN mkdir -p ${FTP_USERS_DIR} && \
    chown ${FTP_USER}:${FTP_GROUP} ${FTP_USERS_DIR} && \
    chmod 755 ${FTP_USERS_DIR}

# Expose FTP ports (FTP, FTPS, Passive Ports)
EXPOSE 21 990 60000-60100

# Start ProFTPD
CMD ["proftpd", "--nodaemon"]