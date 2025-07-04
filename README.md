# Welcome to **Oled's helm charts**
This repository is a collection of some custom helm charts adapted and packaged by Oled1.

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/oleds-helm-charts)](https://artifacthub.io/packages/search?repo=oleds-helm-charts)

> **This Helm chart repository is a custom helm chart packaged by OLED1**.
> There is no official support from any app developer itself except "Chia(R) Manager" (because I am the developer).
> Active unofficial supported charts. If a new version will be released a new updated package will be created.
> Please NOTE: The charts a mostly new and you might still find some bugs.

## Why are there already existing Helm Charts?
Yes it's true, some of my charts are already existing out there, but the already existing ones are partially poorly implemented. Sometimes the values files are just a joke.
So i decided to create my own ones with a higher quality and much more documentation. If you found some settings which are missing or mistakable please contact me. I will change it as soon as possible.

## Applications
### Typemill
![Version: 0.1.6](https://img.shields.io/badge/Version-0.1.6-informational?style=flat-square) ![AppVersion: 1.5.3-4](https://img.shields.io/badge/AppVersion-1.5.3.4-informational?style=flat-square)

See Typemill HELM Documentation: [here](https://github.com/OLED1/oleds-helm-charts/blob/main/helm-development/typemill/README.md)

### CMSMS (CMS Made Simple)
![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![AppVersion: 2.2.16](https://img.shields.io/badge/AppVersion-2.2.16-informational?style=flat-square)

See CMSMS HELM Documentation: [here](https://github.com/OLED1/oleds-helm-charts/blob/main/helm-development/cmsms/README.md)

### Chia(R) Manager
> Currently in progress.

### Bookstack
> Currently in progress.

### Database Backup Tool
![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

See DB-Dumper HELM Documentation: [here](https://github.com/OLED1/oleds-helm-charts/blob/main/helm-development/db-backup/README.md)

| Chart Name | App name | App documentation | Official | App Version | Helm Version |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| Typemill  | typemill  | [click me](https://typemill.net/getting-started) | No | 1.5.3.4 | 0.1.6 |
| CMSMS    | cmsms  | [click me](https://docs.cmsmadesimple.org/) | No | 2.2.16 | 0.1.4 |
| Chia(R) Manager  | chia-manager | [click me](https://docs.chia-manager.org/) | Yes | 0.1.3.alpha | None |
| Database Backup Tool | db-backup  | [click me](https://github.com/OLED1/oleds-helm-charts/blob/main/helm-development/db-backup/README.md) | Yes | 0.1.0 | 0.1.0 |

## Install
### Prerequisites
- Kubernetes installed
- Helm installed and configured. [See here](https://helm.sh/docs/intro/install/)
- (Optional) Kubeapps (Helm GUI) installed. [See here](https://tanzu.vmware.com/developer/guides/kubeapps-gs/)

### Productive
Oled's stable helm charts.
```
helm repo add oleds-charts https://github.com/OLED1/oleds-helm-charts/raw/main/oleds-charts
```
#### Included Apps
| Chart Name | App name | App Version | Helm Version |
| ------------- | ------------- | ------------- | ------------- |
| Typemill  | typemill | 1.5.3.4 | 0.1.6 | 
| CMSMS    | cmsms | 2.2.16 | 0.1.4 |
| Database Backup Tool | db-backup | 0.1.0 | 0.1.0 |
| Automx2| automx2 | 2025.1.1 | 1.0.0 |

### Staging (Use with caution!)
Oled's helm charts which are currently in testing phase.
```
helm repo add oleds-charts-staging https://github.com/OLED1/oleds-helm-charts/raw/main/oleds-charts-staging
```
#### Included Apps
| Chart Name | App name | App Version | Helm Version |
| ------------- | ------------- | ------------- | ------------- |

### Development (DO NOT USE!)
Oled's helm charts which are currently in development.
```
helm repo add oleds-charts-dev https://github.com/OLED1/oleds-helm-charts/raw/main/oleds-charts-dev
```
#### Included Apps
| Chart Name | App name | App Version | Helm Version |
| ------------- | ------------- | ------------- | ------------- |
| Typemill  | typemill | 1.5.3.4 | 0.1.45-dev | 
| CMSMS    | cmsms | 2.2.16 | 0.1.31-dev |
| Database Backup Tool | db-backup | 0.1.0 | 0.1.14-dev |
