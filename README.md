# Bitwarden Portal
Automate backup and restore between Bitwarden and/or Vaultwarden vault.

<p align="center">
  <img src="logo.png" alt=""/>
</p>

[![Docker Image - 1.0.1](https://img.shields.io/docker/v/reaper0x1/bitwarden-portal/latest?logo=docker&label=Docker%20Image)](https://hub.docker.com/r/reaper0x1/bitwarden-portal)
[![Github - Official](https://img.shields.io/badge/Github-Official-2dba4e?logo=github)](https://github.com/Reaper0x1/bitwarden-portal)

## Table of Contents
- [Description](#description)
- [Features](#features)
- [How It Works](#how-it-works)
- [Environment Variables](#environment-variables)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Docker Compose with .env file](#docker-compose-with-env-file)
  - [Docker Compose with env variables](#docker-compose-with-env-variables)
  - [Build Locally](#build-locally)
- [Roadmap](#roadmap)
- [[WIP] Self-Signed Certificate](#self-signed-certificate)

## Description

The goal of this project was to create a backup process of a Bitwarden vault to a self-hosted Vaultwarden instance, ensuring there is always a copy in case the official Bitwarden becomes unavailable.

This docker image automates the **backup** and **restore** process for a Bitwarden vault. It provides functionalities for exporting, encrypting, and managing backup versions.
Additionally, the script securely deletes outdated files while maintaining a minimum number of recent backups.

**✅ This script works for Bitwarden as well as Vaultwarden**


## Features

- **🕛 Automated Backup**: Exports vault data in JSON format with CRON schedule.
- **🔒 File Encryption**: Protects backup files with AES-256-CBC encryption using a password.
- **🧹 Cleanup of Old Backups**: Removes outdated files based on customizable retention policies.
- **🤖 Automated Restore**: Decrypts and imports backups into another Bitwarden vault.
- **📂 Complete Vault Management**: Deletes folders, items, and attachments in the destination before restoring.
- **😊 Compatibility**: Uses Bitwarden API Key for secure vault access.
- **✒️ Self-Signed certificate**: Supports self-signed certificates for local domain.
- ❌ Does not support attachments backup

## How It Works

1. **Source Vault Backup**
   - Exports the vault in JSON format.
   - Encrypts the exported file.
   - Deletes outdated files while retaining recent backups.

2. **Destination Vault Cleanup**
   - Exports the current content of the destination vault.
   - Deletes folders, items, and attachments.

3. **Destination Vault Restore**
   - Decrypts the latest source vault backup.
   - Imports the decrypted backup into the destination vault.


## Environment Variables
The script uses the following environment variables for backup and restore configuration:

- **Script Config**
  - `CRON_SCHEDULE`: Your backup cron schedule (Default: `0 0 * * *` = every day at 00:00)   
    You can generate one at [crontab.guru](https://crontab.guru/).

- **Authentication**
  - `SOURCE_ACCOUNT`: Email for the source vault.
  - `SOURCE_PASSWORD`: Password for the source vault.
  - `SOURCE_CLIENT_ID`: Client ID for the source vault.
  - `SOURCE_CLIENT_SECRET`: Client Secret for the source vault.

  - `DEST_ACCOUNT`: Email for the destination vault.
  - `DEST_PASSWORD`: Password for the destination vault.
  - `DEST_CLIENT_ID`: Client ID for the destination vault.
  - `DEST_CLIENT_SECRET`: Client Secret for the destination vault.

    See [prerequisites](#prerequisites) for how to get **Client ID** and **Client Secret**.

- **Server Configuration**
  - `SOURCE_SERVER`: URL of the Bitwarden/Vaultwarden server for the source vault.
  - `DEST_SERVER`: URL of the Bitwarden/Vaultwarden server for the destination vault.  

**Note**: You can use both Bitwarden and Vaultwarden for source and destination. If your are using a self-hosted Vaultwarden with a **self-signed certificate** for the domain see [Self-Signed Certificate](#self-signed-certificate) section below.

- **Security Parameters**
  - `ENCRYPTION_PASSWORD`: Password used to encrypt and decrypt backup files.

- **File Management**
  - `PUID`: User ID to set file permissions.
  - `PGID`: Group ID to set file permissions.
  - `ENABLE_PRUNING`: If set to `false` no backups will be pruned. (Default: `true`)
  - `RETENTION_DAYS`: Number of days after which outdated files can be deleted. Backups older than this value will be deleted.
  - `MIN_FILES`: Minimum number of backup files to retain. If all your backups are older than RETENTION_DAYS, keep the minimum files based on this value.

### Directories Created

- **Backup Folders**
  - `backups/source`: Folder for source vault backups.
  - `backups/dest`: Folder for destination vault backups.


## Getting Started

### Prerequisites

1. **🐋 Docker** must be installed and configured.
2. Configure access for source and destination vaults (using API Key credentials).
    - To get both source and destination Client ID and Client Secret you need to go in `Account Settings` -> `Security` -> `Keys`.

### Docker Compose with .env file
```yaml
services:
    bitwarden-portal:
        image: reaper0x1/bitwarden-portal:latest
        container_name: bitwarden-portal
        env_file: .env
        volumes:
            - your-backups-folder:/app/backups
        restart: unless-stopped
```
- Change `your-backups-folder` to your backup folder.
- Create a `.env` file and set the variables. (See `.env.example` as reference)

### Docker Compose with env variables
```yaml
services:
    bitwarden-portal:
        image: reaper0x1/bitwarden-portal:latest
        container_name: bitwarden-portal
        environment:
            # Put your cron schedule. 
            - CRON_SCHEDULE=0 0 * * *
            # Your timezone.
            - TZ=Europe/Berlin
            # This is the password used to encrypt and decrypt the backup files.
            - ENCRYPTION_PASSWORD=strong-password
            # Your Bitwarden/Vaultwarden SOURCE login info.
            - SOURCE_ACCOUNT=source@mail.com
            - SOURCE_PASSWORD=source-password
            # You can find these two in Account Settings -> Security -> Keys.
            - SOURCE_CLIENT_ID=user.xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
            - SOURCE_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            # Your source server domain/IP.
            - SOURCE_SERVER=https://vault.bitwarden.com
            # Your Bitwarden/Vaultwarden DESTINATION login info.
            - DEST_ACCOUNT=dest@mail.com
            - DEST_PASSWORD=dest-password
            # You can find these two in Account Settings -> Security -> Keys.
            - DEST_CLIENT_ID=user.xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
            - DEST_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            # Your source server domain/IP.
            - DEST_SERVER=http://192.168.1.10:8888 # Can be https://vaultwarden.myserver.local if using self-signed certificate.
            # The users belongs to process and files.
            - PUID=1000
            - PGID=1000
            # Enable/Disable backups pruning (false/true)
            - ENABLE_PRUNING=true
            # Your retention policy for backup files. Backup older than this value will be deleted.
            - RETENTION_DAYS=30
            # If all your backups are older than RETENTION_DAYS, keep the following minimum files.
            - MIN_FILES=10
        volumes:
            - your-backups-folder:/app/backups
        restart: unless-stopped
```
- Change env variables to match your setup.
- Change `your-backups-folder` to your backup folder.

### Build Locally
1. Clone the repo and enter the directory:  
    ```bash
    git clone https://github.com/Reaper0x1/bitwarden-portal.git && cd bitwarden-portal
    ```
2. Create a `.env` file and set the variables. (See `.env.example` as reference)
3. Start the container:  
    ```bash
    docker compose up -d
    ```
    
## Roadmap
- Self-signed certificate with docker-compose (not only by local build).
- Output logs.
- Attachments backup and transfer.

## Self-Signed Certificate
**[WIP**]  
If you are using a local domain with a self-signed certificate for SSL, you need to put your certificate inside the `Certs` folder.

- **Build image locally**: just put the `.crt` file inside the `certs` folder.
- **Usign Docker Hub Image**: TO-DO
