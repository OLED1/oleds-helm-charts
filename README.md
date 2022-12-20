# Welcome to **Oled's helm charts**
This repository is a collection of some custom helm charts adapted and packaged by Oled1.

> **This Helm chart repository is a custom helm chart packaged by OLED1**.
> There is no official support from any app developer itself except "Chia(R) Manager" (because I am the developer).
> Active unofficial supported charts. If a new version will be released a new updated package will be created.
> Please NOTE: The charts a mostly new and you might still find some bugs.

## Applications
### Typemill
See Typemill HELM Documentation: [here](https://github.com/OLED1/oleds-helm-charts/blob/main/helm-development/typemill/README.md)

### CMSMS (CMS Made Simple)
See CMSMS HELM Documentation: [here](https://github.com/OLED1/oleds-helm-charts/blob/main/helm-development/cmsms/README.md)

### Chia(R) Manager
> Currently in progress.

### Databse Backup Tool
See DB-Dumper HELM Documentation: [here](https://github.com/OLED1/oleds-helm-charts/blob/main/helm-development/db-backup/README.md)

| Chart Name | App name | App documentation | Official | App Version | Helm Version |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| Typemill  | typemill  | [click me](https://typemill.net/getting-started) | No | 1.5.3.4 | 0.1.4 |
| CMSMS    | cmsms  | [click me](https://docs.cmsmadesimple.org/) | No | 2.2.16 | 0.1.3 |
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
| Typemill  | typemill | 1.5.3.4 | 0.1.4 | 
| CMSMS    | cmsms | 2.2.16 | 0.1.3 |
| Database Backup Tool | db-backup | 0.1.0 | 0.1.0 |

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
| Typemill  | typemill | 1.5.3.4 | 0.1.41-dev | 
| CMSMS    | cmsms | 2.2.16 | 0.1.30-dev1 |
| Database Backup Tool | db-backup | 0.1.0 | 0.1.14-dev |
