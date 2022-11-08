# DB-Backup helm chart

> **This Helm chart is a custom helm chart packaged by OLED1**.
> If you are missing some features tell me, i will try to implement them.

## Prerequisites
- Kubernetes installed
- Helm installed and configured. [See here](https://helm.sh/docs/intro/install/)
- (Optional) Kubeapps (Helm GUI) installed. [See here](https://tanzu.vmware.com/developer/guides/kubeapps-gs/)

## Short app description
This app is a kubernetes cronjob container which runs periodically and dumps your (MYSQL) database.
This dumps then uploaded to a configured webdav share (Tested with Nextcloud) or to an existing pv.

## Documentation
### Features
- Currently only MYSQL databse(s) can be dumped
- Dumps multiple databases in a single namespace at once (you can state only one host)
- When using an external database, you can dump multiple databases at once
- Uploads the dumps automatically to a webdav share (Tested with Nextcloud)
- Copies the dumps automatically to an existing pv or an NFS Share
- Sends an e-mail when a backup ends with details about the process

## Installation
### Backup job execution

### Webdav share setup

### Existing PV setup

### NFS share setup

### Setup mailing

## Feature missing or bug found
Please tell me by open a github issue: [oleds-helm-charts](https://github.com/OLED1/oleds-helm-charts).

## Whats new?
### Chart Version 0.1.0
- First version of the tool
- Supports only MySQL/MariaDB dumping
- See further features in the "features" section

## FAQ
If you have a feature request or found a bug, open a github issue [here](https://github.com/OLED1/oleds-helm-charts).
There are currently no open questions. You ask me, I will answer ;)
