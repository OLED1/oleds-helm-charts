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
> Currently in progress. See DB-Dumper HELM Documentation: [here]https://github.com/OLED1/oleds-helm-charts/blob/main/helm-development/db-backup/README.md

## Install
### Prerequisites
- Kubernetes installed
- Helm installed and configured. [See here](https://helm.sh/docs/intro/install/)
- (Optional) Kubeapps (Helm GUI) installed. [See here](https://tanzu.vmware.com/developer/guides/kubeapps-gs/)

### Productive
```
helm repo add oleds-charts https://github.com/OLED1/oleds-helm-charts/raw/main/oleds-charts
```
### Development (DO NOT USE!)
```
helm repo add oleds-charts-dev https://github.com/OLED1/oleds-helm-charts/raw/main/oleds-charts-dev
```