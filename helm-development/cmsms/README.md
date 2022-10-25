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
This helm chart fully installs the CMSMS (CMS Made Simple) App with default content and stylesheets.
Just fill out the values.yaml file or use Visual Editor to deploy the application.

> Please Note: Pretty URL's are configured per default. Just use the default htaccess file.

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

## FAQ
If you have a feature request or found a bug, open a github issue [here](https://github.com/OLED1/oleds-helm-charts).
There are currently no open questions. You ask me, I will answer ;)
