<p align="center">
		<img src="https://raw.githubusercontent.com/serversideup/docker-proftpd/main/.github/header.png" width="1200" alt="Docker Images Logo">
</p>
<p align="center">
	<a href="https://actions-badge.atrox.dev/serversideup/docker-proftpd/goto?ref=main"><img alt="Build Status" src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fserversideup%2Fdocker-proftpd%2Fbadge%3Fref%3Dmain&style=flat" /></a>
	<a href="https://github.com/serversideup/docker-proftpd/blob/main/LICENSE" target="_blank"><img src="https://badgen.net/github/license/serversideup/docker-proftpd" alt="License"></a>
	<a href="https://github.com/sponsors/serversideup"><img src="https://badgen.net/badge/icon/Support%20Us?label=GitHub%20Sponsors&color=orange" alt="Support us"></a>
	<a href="https://community.serversideup.net"><img alt="Discourse users" src="https://img.shields.io/discourse/users?color=blue&server=https%3A%2F%2Fcommunity.serversideup.net"></a>
  <a href="https://serversideup.net/discord"><img alt="Discord" src="https://img.shields.io/discord/910287105714954251?color=blueviolet"></a>
</p>

# ProFTPD Docker Image

> [!CAUTION]
> We created this image for a specific use case. We're not actively pursuing to expand features in this project. We just had a legacy integration to deal with on a customer project, so we created this image in case others might find it useful.

This Docker image provides a customizable ProFTPD server with MySQL authentication support and TLS encryption.

| Docker Image | Size |
|--------------|------|
| [**serversideup/proftpd**](https://hub.docker.com/r/serversideup/proftpd) | [![Docker Image Size](https://img.shields.io/docker/image-size/serversideup/proftpd/latest?style=flat-square)](https://hub.docker.com/r/serversideup/proftpd) |

## Base Image
The image is based on `ubuntu:24.04`, providing a stable and up-to-date environment for running ProFTPD.

## Features
- ProFTPD server with MySQL authentication
- TLS encryption support
- Customizable configuration via environment variables
- Self-signed SSL certificate generation
- IP address banning (bans IP addresses for 1 hour that fail authentication 5 times in 10 minutes)

## Environment Variables

The following environment variables can be used to customize the ProFTPD server:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `FTP_DEBUG_LEVEL` | Sets the debug level for ProFTPD | 0 |
| `FTP_LOG_LEVEL` | Sets the syslog level for ProFTPD | warn |
| `FTP_MASQUERADE_ADDRESS` | IP address or hostname for passive mode connections | - |
| `FTP_PASSIVE_PORT_RANGE_START` | Start of the passive port range | 60000 |
| `FTP_PASSIVE_PORT_RANGE_END` | End of the passive port range | 60100 |
| `FTP_SQL_USERS_TABLE` | MySQL table to authenticate users against | ftpusers |
| `FTP_TLS_CERTIFICATE_FILE` | SSL certificate file | /etc/ssl/ftp/proftpd.crt |
| `FTP_TLS_CERTIFICATE_KEY_FILE` | SSL certificate key file | /etc/ssl/ftp/proftpd.key |
| `FTP_TLS_REQUIRED` | Require TLS | off |
| `MYSQL_DATABASE` | MySQL database name | ftpdb |
| `MYSQL_HOST` | MySQL host | mysql |
| `MYSQL_PASSWORD` | MySQL password | ftppassword |
| `MYSQL_PORT` | MySQL port | 3306 |
| `MYSQL_USER` | MySQL user | ftpuser |

## Build Defaults

The following build arguments are used during the image build process:

| Build Argument | Description | Value |
|----------------|-------------|---------------|
| `FTP_USER` | The user under which ProFTPD will run | proftpd_user |
| `FTP_GROUP` | The group under which ProFTPD will run | nogroup |
| `FTP_SSL_CERTS_DIR` | Directory for SSL certificates | /etc/ssl/ftp |
| `FTP_USERS_DIR` | Base directory for user homes | /var/ftp/users |

## Usage

1. Build the Docker image:

```bash
docker build -t proftpd-mysql .
```

2. Run the container:

```yml
services:
  proftpd:
    image: serversideup/proftpd
    ports:
      - "21:21"
      - "990:990"
      - "60000-60100:60000-60100"
    environment:
      - MYSQL_HOST=your_mysql_host
      - MYSQL_DATABASE=your_database
      - MYSQL_USER=your_user
      - MYSQL_PASSWORD=your_password
      - FTP_MASQUERADE_ADDRESS=your_masquerade_address
```

Make sure to replace the MySQL connection details with your own.

## Configuration

The ProFTPD configuration file (`proftpd.conf`) is included in the image. It sets up the following:

- FTP and FTPS (TLS) support
- MySQL authentication
- Passive port range: 60000-60100
- TLS Protocol: TLSv1.2 and TLSv1.3
- Logging configuration
- Home directory creation for users
- Anonymous access disabled
- IP address banning (bans IP addresses for 1 hour that fail authentication 5 times in 10 minutes)
You can modify the `proftpd.conf` file to further customize the ProFTPD server according to your needs.

## Security Considerations

- The image generates a self-signed SSL certificate for FTPS. For production use, replace it with a valid SSL certificate.
- Ensure to use strong passwords for MySQL authentication.
- Review and adjust the `proftpd.conf` file to match your security requirements.
- Consider using Docker secrets or a secure method to pass sensitive information like database credentials.

## Ports

The following ports are exposed:

| Port | Service |
|------|---------|
| 21 | FTP |
| 990 | FTPS (FTP over TLS) |
| 60000-60100 | Passive port range |

### Special Note on orchestrators
If you are using an orchestrator like Kubernetes, you will need to ensure that the ports are opened on the container and the host.

For example, for Docker Swarm you need to use the long format for the `ports` directive in your docker compose file:

```yml
services:
  ftp:
    image: serversideup/proftpd
    ports:
      - target: 21
        published: 21
        protocol: tcp
        mode: host
      - target: 990
        published: 990
        protocol: tcp
        mode: host
      - target: 60000
        published: 60000
        protocol: tcp
        mode: host
      - target: 60001
        published: 60001
        protocol: tcp
        mode: host
      - target: 60002
        published: 60002
        protocol: tcp
        mode: host
```

Unfortunately, Docker Swarm does not support specifying ranges for published ports with the long format, so you need to specify each port individually. Just be sure to open all ports within the range that you define within the `FTP_PASSIVE_PORT_RANGE_START` and `FTP_PASSIVE_PORT_RANGE_END` environment variables.

## MySQL Database
You can use either MySQL or MariaDB. Create a table in the database with the following SQL:

```sql
CREATE TABLE ftpusers (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- Auto-incrementing primary key
    username VARCHAR(255) NOT NULL,     -- Username, max length 255 characters
    password VARCHAR(255) NOT NULL,     -- Password, max length 255 characters
    uid INT NOT NULL,                   -- User ID, integer type
    gid INT NOT NULL,                   -- Group ID, integer type
    homedir VARCHAR(255) NOT NULL,      -- Home directory path, max length 255 characters
    shell VARCHAR(255) NOT NULL         -- Shell, max length 255 characters
);
```

Then you can add users to the database with the following SQL:

```sql
INSERT INTO ftpusers (username, password, uid, gid, homedir, shell)
VALUES (
  'testuser',
  CONCAT('{sha256}', TO_BASE64(UNHEX(SHA2('mypassword', 256)))),
  2001,
  2001,
  '/var/ftp/users/testuser',
  '/bin/false'
);
```

## Resources
- **[Discord](https://serversideup.net/discord)** for friendly support from the community and the team.
- **[GitHub](https://github.com/serversideup/docker-proftpd)** for source code, bug reports, and project management.
- **[Get Professional Help](https://serversideup.net/professional-support)** - Get video + screen-sharing help directly from the core contributors.

## Contributing
As an open-source project, we strive for transparency and collaboration in our development process. We greatly appreciate any contributions members of our community can provide. Whether you're fixing bugs, proposing features, improving documentation, or spreading awareness - your involvement strengthens the project.

- **Bug Report**: If you're experiencing an issue while using these images, please [create an issue](https://github.com/serversideup/docker-proftpd/issues/new/choose).
- **Security Report**: Report critical security issues via [our responsible disclosure policy](https://www.notion.so/Responsible-Disclosure-Policy-421a6a3be1714d388ebbadba7eebbdc8).

Need help getting started? Join our Discord community and we'll help you out!

<a href="https://serversideup.net/discord"><img src="https://serversideup.net/wp-content/themes/serversideup/images/open-source/join-discord.svg" title="Join Discord"></a>

## Our Sponsors
All of our software is free an open to the world. None of this can be brought to you without the financial backing of our sponsors.

<p align="center"><a href="https://github.com/sponsors/serversideup"><img src="https://521public.s3.amazonaws.com/serversideup/sponsors/sponsor-box.png" alt="Sponsors"></a></p>

#### Bronze Sponsors
<!-- bronze -->No bronze sponsors yet. <a href="https://github.com/sponsors/serversideup">Become a sponsor →</a><!-- bronze -->

#### Individual Supporters
<!-- supporters --><a href="https://github.com/GeekDougle"><img src="https://github.com/GeekDougle.png" width="40px" alt="GeekDougle" /></a>&nbsp;&nbsp;<a href="https://github.com/JQuilty"><img src="https://github.com/JQuilty.png" width="40px" alt="JQuilty" /></a>&nbsp;&nbsp;<a href="https://github.com/MaltMethodDev"><img src="https://github.com/MaltMethodDev.png" width="40px" alt="MaltMethodDev" /></a>&nbsp;&nbsp;<!-- supporters -->

## About Us
We're [Dan](https://twitter.com/danpastori) and [Jay](https://twitter.com/jaydrogers) - a two person team with a passion for open source products. We created [Server Side Up](https://serversideup.net) to help share what we learn.

<div align="center">

| <div align="center">Dan Pastori</div>                  | <div align="center">Jay Rogers</div>                                 |
| ----------------------------- | ------------------------------------------ |
| <div align="center"><a href="https://twitter.com/danpastori"><img src="https://serversideup.net/wp-content/uploads/2023/08/dan.jpg" title="Dan Pastori" width="150px"></a><br /><a href="https://twitter.com/danpastori"><img src="https://serversideup.net/wp-content/themes/serversideup/images/open-source/twitter.svg" title="Twitter" width="24px"></a><a href="https://github.com/danpastori"><img src="https://serversideup.net/wp-content/themes/serversideup/images/open-source/github.svg" title="GitHub" width="24px"></a></div>                        | <div align="center"><a href="https://twitter.com/jaydrogers"><img src="https://serversideup.net/wp-content/uploads/2023/08/jay.jpg" title="Jay Rogers" width="150px"></a><br /><a href="https://twitter.com/jaydrogers"><img src="https://serversideup.net/wp-content/themes/serversideup/images/open-source/twitter.svg" title="Twitter" width="24px"></a><a href="https://github.com/jaydrogers"><img src="https://serversideup.net/wp-content/themes/serversideup/images/open-source/github.svg" title="GitHub" width="24px"></a></div>                                       |

</div>

### Find us at:

* **📖 [Blog](https://serversideup.net)** - Get the latest guides and free courses on all things web/mobile development.
* **🙋 [Community](https://community.serversideup.net)** - Get friendly help from our community members.
* **🤵‍♂️ [Get Professional Help](https://serversideup.net/professional-support)** - Get video + screen-sharing support from the core contributors.
* **💻 [GitHub](https://github.com/serversideup)** - Check out our other open source projects.
* **📫 [Newsletter](https://serversideup.net/subscribe)** - Skip the algorithms and get quality content right to your inbox.
* **🐥 [Twitter](https://twitter.com/serversideup)** - You can also follow [Dan](https://twitter.com/danpastori) and [Jay](https://twitter.com/jaydrogers).
* **❤️ [Sponsor Us](https://github.com/sponsors/serversideup)** - Please consider sponsoring us so we can create more helpful resources.

## Our products
If you appreciate this project, be sure to check out our other projects.

### 📚 Books
- **[The Ultimate Guide to Building APIs & SPAs](https://serversideup.net/ultimate-guide-to-building-apis-and-spas-with-laravel-and-nuxt3/)**: Build web & mobile apps from the same codebase.
- **[Building Multi-Platform Browser Extensions](https://serversideup.net/building-multi-platform-browser-extensions/)**: Ship extensions to all browsers from the same codebase.

### 🛠️ Software-as-a-Service
- **[Bugflow](https://bugflow.io/)**: Get visual bug reports directly in GitHub, GitLab, and more.
- **[SelfHost Pro](https://selfhostpro.com/)**: Connect Stripe or Lemonsqueezy to a private docker registry for self-hosted apps.

### 🌍 Open Source
- **[AmplitudeJS](https://521dimensions.com/open-source/amplitudejs)**: Open-source HTML5 & JavaScript Web Audio Library.
- **[Spin](https://serversideup.net/open-source/spin/)**: Laravel Sail alternative for running Docker from development → production.
- **[Financial Freedom](https://github.com/serversideup/financial-freedom)**: Open source alternative to Mint, YNAB, & Monarch Money.