# CMS Made Simple helm chart

> **This Helm chart is a custom helm chart packaged by OLED1**.
> There is no official support from CMS Made Simple (CMS Made Simple Foundation) itself.
> Active unofficial supported chart. If a new version will be released a new updated package will be created.

## Prerequisites
- Kubernetes installed
- Helm installed and configured
- (Optional) Kubeapps (Helm GUI) installed (https://tanzu.vmware.com/developer/guides/kubeapps-gs/)

## Documentation
- The official documentation can be found here: https://docs.cmsmadesimple.org/

## Installation
It's a straight forward installation procedure. Just fill out the values.yaml file and deploy it.

> Please Note: Pretty URL's are configured per default. Just use the default htaccess file.

### Not included in visual editor
#### Ingress hostname and tls configuration

#### Certbot configuration (SSL autoconfiguration)

#### Using existing secrets

#### Additional CMSMS config

#### PHP INI Settings

#### Custom htaccess configuration

## Migrating
If you plan to move an existing installation you just need follow the upcomming steps:
1. Skip the installation by set **install_cmsms: false**.
2. Backup the existing **"modules"** and **"uploads"** directory.
3. Backup your existing database.
4. Import the previously backed up **"modules"** and **"uploads"** directory to the newly created CMSMS-PV.
5. Import the previously backed up database to the newly created DB-PV and import it by exec into the db container.
6. That's it.

## Feature configuration documentation


## Feature missing or bug found
Please tell me by open a github issue: [oleds-helm-charts](https://github.com/OLED1/oleds-helm-charts).

## Whats new?
### Chart Version 0.1.0
- First release of CMS Made Simple Helm Chart
- CMSMS Version 2.2.16

## FAQ
If you have a feature request or found a bug, open a github issue [here](https://github.com/OLED1/oleds-helm-charts).
There are currently no open questions. You ask me, I will answer ;)
