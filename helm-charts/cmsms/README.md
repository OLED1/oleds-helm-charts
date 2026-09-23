# CMS Made Simple helm chart

> **This Helm chart is a custom helm chart packaged by OLED1**.
> There is no official support from CMS Made Simple (CMS Made Simple Foundation) itself.
> Active unofficial supported chart. If a new version will be released a new updated package will be created.

## BREAKING CHANGES by upgrading 0.1.x to 0.2.x !!!

### From 0.1.x to 0.2.0

> **⚠️ 0.2.0 contains breaking changes.** Review your values file before upgrading.
> Do **not** use `helm upgrade --reuse-values` for this upgrade — pass your adapted values file explicitly.

#### Existing secrets: new format, legacy format still accepted

All `existingSecret` settings now accept a plain **string** (the secret name), following the
Bitnami convention. Empty string = disabled. When set, the plain-text credentials of that
section are ignored. The name is rendered through `tpl`, so `"{{ .Release.Name }}-creds"` works.

With the string format, the secret must use the same key names as the chart-generated secret:

| Setting | Required keys |
|---|---|
| `externalDatabase.existingSecret` | `db-username`, `db-password` |
| `cmsms_settings.db_authentication.existingSecret` *(new)* | `db-username`, `db-password` |
| `cmsms_settings.initial_user.existingSecret` | `cmsms_username`, `cmsms_password`, `cmsms_email` |
| `cmsms_settings.setup_smtp.smtp_auth.existingSecret` | `cmsms_smtp_username`, `cmsms_smtp_password` |
| `mariadb.auth.existingSecret` *(Bitnami, string only)* | `mariadb-root-password`, `mariadb-password` |

**New format (recommended):**

```yaml
externalDatabase:
  existingSecret: my-db-secret   # must contain db-username / db-password
```

**Legacy format (deprecated, still supported in 0.2.x):**

```yaml
externalDatabase:
  existingSecret:
    enabled: true
    secretName: my-db-secret
    usernameKey: user        # optional, custom key names are honored
    passwordKey: pass
    # emailKey: mail         # initial_user only
```

The legacy object format keeps working, including custom key names. `helm install/upgrade`
prints a **deprecation warning** listing the affected settings. It will be removed in a future
release — migrate to the string format.

When using the legacy format, Helm may log a harmless warning like:

```
coalesce.go:289: warning: destination for cmsms.cmsms_settings.initial_user.existingSecret is a table. Ignoring non-table value ()
```

This only means Helm replaced the string default from `values.yaml` with your object. The rendered
output is correct. The warning disappears once you switch to the string format.

Typos in the legacy object (e.g. `secretname`) are rejected by the schema.
`mariadb.auth.existingSecret` is passed to the Bitnami subchart and **must** be a string.

#### Internal database with `mariadb.auth.existingSecret`

New section `cmsms_settings.db_authentication`. When `mariadb.auth.existingSecret` is set,
CMSMS takes its database credentials from here:

- `db_authentication.existingSecret`: secret with `db-username` / `db-password`, **or**
- `db_authentication.username` / `password`: must match `mariadb-password` in the MariaDB secret.

Without `mariadb.auth.existingSecret`, `mariadb.auth.username` / `password` are used as before.

#### Other breaking changes

- **`nameOverride` / `fullnameOverride` moved to the top level.** Under `cmsms_app` they never had an effect.
  Setting them now changes resource names; only set them if you actually want that.
- **External database no longer gets `MYSQL_ROOT_PASSWORD`.** Previously the pod referenced a
  non-existent `<release>-mariadb` secret in this mode.
- **`smtp_auth.auth_needed: false` is now respected.** It previously always rendered `"true"`.
- **SMTP credentials are required** when `auth_needed: true` and no `existingSecret` is set.
  The fallback defaults (`cmsms_smtp` / `changeme!`) were removed.
- **Initial admin password is now persistent.** If `initial_user.password` is empty, the generated
  password is kept across upgrades (via `lookup`). With `helm template` / ArgoCD, `lookup` is not
  available: set the password explicitly or use `existingSecret`.
- **`cmsms_app.strategy` is now applied** (default: `RollingUpdate`, `maxSurge: 1`, `maxUnavailable: 0`).
  With `persistence.accessMode: ReadWriteOnce`, the new pod may fail with a *Multi-Attach* error if
  scheduled on another node — use `ReadWriteMany` or set `strategy.type: Recreate`.
- **Pods restart on secret changes** (checksum annotations on the pod template).
- **Chart-generated secrets are only rendered when needed.** When you switch to an `existingSecret`,
  Helm deletes the now-unused `<release>-db` / `<release>-secrets`.
- **Validation:** `mariadb.enabled` and `externalDatabase.enabled` must not both be `true`.
- **`helm test` fixed:** the connection test now targets the correct service (`<fullname>-app`).

#### Upgrade procedure

```bash
# 1. Compare your values with the new defaults
helm show values <repo>/cmsms --version 0.2.0 > values-0.2.0.yaml
diff -u my-values.yaml values-0.2.0.yaml

# 2. Adapt your values (see above); legacy existingSecret objects may stay for now

# 3. Render and review before applying
helm template my-release <repo>/cmsms --version 0.2.0 -f my-values.yaml

# 4. Upgrade with the adapted values file (no --reuse-values)
helm upgrade my-release <repo>/cmsms --version 0.2.0 -f my-values.yaml
```

## Prerequisites
- Kubernetes installed
- Helm installed and configured. [See here](https://helm.sh/docs/intro/install/)
- (Optional) Kubeapps (Helm GUI) installed. [See here](https://tanzu.vmware.com/developer/guides/kubeapps-gs/)

## Short app description
CMS Made Simple (CMSMS) is a free, open source (GPL) content management system (CMS) to provide developers, programmers and site owners a web-based development and administration area. In 2017 it won the CMS Critic annual award for Best Open Source Content Management.

## Documentation
- The official documentation can be found here: https://docs.cmsmadesimple.org/

## Installation
This helm chart fully installs the CMSMS (CMS Made Simple) App with default content and stylesheets.
Just fill out the values.yaml file or use Visual Editor to deploy the application.

> Please Note: Pretty URL's are configured per default. Just use the default htaccess file.

### Set container timezone
Some system modules need a correct system time like the news module.
In the following list you can find valid settings. [See here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List)
```
cmsms_settings:
  app_config:
    timezone: Europe/Vienna #<--- Just an example. Use your timezone.
```
### Not included in visual editor
#### Ingress hostname and tls configuration
By setting up the ingress controller your application can be made available through the internet.
By adapting and applying the following config your application will be available externally.

##### Externally available through HTTP
```
ingress:
  enabled: true
  className: "nginx" #<--- Just an example. Use your setup ingress.
  hosts:
    - host: my-cmsms.example.org #<--- Just an example. Use your domainname.
      paths:
        - path: /
          pathType: ImplementationSpecific
```
This config makes your application available via http.

##### Externally available through HTTPS
**Edit values.yaml:**
```
ingress:
    enabled: true
    className: "nginx" #<--- Just an example. Use your setup ingress.
    hosts:
    - host: my-cmsms.example.org #<--- Just an example. Use your domainname.
      paths:
        - path: /
          pathType: ImplementationSpecific
    tls:
    - secretName: my-cmsms-ssl-secret
      hosts:
      - my-cmsms.example.org #<--- Just an example. Use your domainname.
```
**Create SSL Certificate secret:**
```
apiVersion: v1
kind: Secret
metadata:
  name: my-cmsms-ssl-secret
  namespace: <CMSMS APP NAMESPACE>
type: kubernetes.io/tls
data:
    server.crt: |
        <crt contents here>
    server.key: |
        <private key contents here>
```
This config makes your application available through https.

#### Certbot configuration (SSL autoconfiguration)
To be able to enable auto ssl configuration by using certbot you need to setup an certificate provider.
Take a look here: https://www.howtogeek.com/devops/how-to-install-kubernetes-cert-manager-and-configure-lets-encrypt/

##### Externally available through HTTPS
**Edit values.yaml:**
```
ingress:
    enabled: true
    className: "nginx" #<--- Just an example. Use your setup ingress.
    annotations: 
        {
            cert-manager.io/cluster-issuer: "letsencrypt-prod", #<--- Just an example. Use the name of your setup certificate provider.
            kubernetes.io/tls-acme: "true"
        }
    hosts:
    - host: my-cmsms.example.org #<--- Just an example. Use your domainname.
      paths:
        - path: /
          pathType: ImplementationSpecific
    tls:
    - secretName: my-cmsms-ssl-secret
      hosts:
      - my-cmsms.example.org #<--- Just an example. Use your domainname.
```

#### Additional CMSMS config
This chart allows you to adapt you cmsms config.
Per default the following values are set:
```
$config['dbms'] = 'mysqli';
$config['db_hostname'] = <CMSMS_DB_HOST>;
$config['db_username'] = <CMSMS_DB_USER>;
$config['db_password'] = <CMSMS_DB_USER_PW>;
$config['db_name'] = <CMSMS_DB>;
$config['db_prefix'] = <CMSMS_DB_PREFIX>;
$config['root_url'] = <CMSMS_DOMAIN>;
$config['timezone'] = <TIMEZONE>;
$config['url_rewriting'] = 'mod_rewrite';
```

By editing **additional_config_settings** setting which can be found under **cmsms_settings -> app_config -> additional_config_settings** you add more settings:
```
additional_config_settings:
- $config['param_key1'] = "param_value1";
- $config['param_key2'] = "param_value2";
```

#### PHP INI Settings
This chart allows you to adapt you php ini config.
Per default the following values are set in the **php_ini_config** section in your values.yaml:
```
cmsms_recommended.ini: |
    upload_max_filesize = 100M
    post_max_size = 100M
    max_execution_time = 60
    output_buffering = on
```

You can adapt it by either editing the preconfigured **cmsms_recommended.ini** setting (DO THIS WITH CAUTION!) or by adding a new file by just appending a new config:
```
cmsms_recommended.ini: |
    upload_max_filesize = 100M
    post_max_size = 100M
    max_execution_time = 60
    output_buffering = on
    my_additional_php_setting = some_value # <--- Like this

# Or like this
my_settings.ini: |
    example_php_setting = example_value
```

#### Custom htaccess configuration
This chart allows you to adapt your htaccess config by setting **use_default_htaccess: true**  to **use_default_htaccess: false** 
and to add content to the **custom_htaccess** directive:
```
custom_htaccess: 
    My custom content
```

#### Modules custom folder (assets/module_custom)
Some modules can be configured by adapting or adding a configuration in the assets/module_custom folder. Well that will be a bit difficult when running in a container. So a symlink from uploads/assets/module_custom/ to assets/module_custom/ was created. Just navigate to the **File Manager** in the WebGUI, head to the assets/module_custom/ folder and upload your files.

## Migrating
If you plan to move an existing installation you just need follow the upcomming steps:
1. Skip the installation by set **install_cmsms: false**.
2. Backup the existing **"modules"** and **"uploads"** directory.
3. Backup your existing database.
4. Import the previously backed up **"modules"** and **"uploads"** directory to the newly created CMSMS-PV.
5. Import the previously backed up database to the newly created DB-PV and import it by exec into the db container.
6. That's it.

## Feature configuration documentation
I tried to add documentation to available settings directly in the values.yaml file.
Watch out for **ref** tags in the comments.

## Feature or documentation missing or bug found
Please tell me by open a github issue: [oleds-helm-charts](https://github.com/OLED1/oleds-helm-charts).

## Whats new?
### Chart Version 0.1.0 (0.1.18-dev) - 25.10.22
- First release of CMS Made Simple Helm Chart
- CMSMS Version 2.2.16
- Added dependency MariaDB 11.0.14

### Chart Version 0.1.1 (0.1.19-dev) - 25.10.22
- MariaDB password generation bug fixed

### Chart Version 0.1.2 (0.1.20-dev) - 25.10.22
- Reverted back to manually adding password

### Chart Version 0.1.3 (0.1.30-dev1) - 15.12.22
- Added timezone setting in **cmsms_settings -> app_config -> timezone: Europe/Vienna**
- Updated documentation

### Chart Version 0.1.4 (0.1.31-dev) - 20.03.23
- Modules custom folder now symlinked from uploads folder (See Details above)
- This chart now actively working with different tags
- Bug fix copying files init script. Added maxdepth.
- Artifact hub changelog added.

### Chart Version 0.1.5 + 0.1.6 (0.1.32-dev) 19.05.26
- Added the option to specify database image.
- Changed version of Bitnami Mariadb to 11.4.*.
- Fixed Artifact Hub CMSMS logo link

## FAQ
If you have a feature request or found a bug, open a github issue [here](https://github.com/OLED1/oleds-helm-charts).
There are currently no open questions. You ask me, I will answer ;)

### Browser Error: Too many redirects
It seems you are using https. Go to the backend and navigate to the "Content Manager". Select all pages by hitting the top right checkbox and set all pages int the bottom left dropdown to "Set insecure (HTTP)". No worries, your instance will still be secure.