# Typemill helm chart

> **This Helm chart is a custom helm chart packaged by OLED1**.
> There is no official support from typemill itself.
> Active unofficial supported chart. If a new version will be released a new updated package will be created.

## Prerequisites
- Kubernetes installed
- Helm installed and configured. [See here](https://helm.sh/docs/intro/install/)
- (Optional) Kubeapps (Helm GUI) installed. [See here](https://tanzu.vmware.com/developer/guides/kubeapps-gs/)

## Short app description
The open-source flat-file cms to create websites and eBooks. Use it for handbooks, documentations, manuals, web-novels, traditional websites, and more.

## Documentation
- The official documentation can be found here: https://typemill.net/getting-started
- Find their github repository here: https://github.com/typemill/typemill

## Installation

> **If you dont want to setup typemill using tls encryption or not using a reverse proxy**:
1. Create you deployment
2. Create your user by accessing http://your-typemill.example.com/setup
3. That's it, you can now setup your typemill instance

> **If you are installing typemill behind a reverse proxy and want to setup tls encryption (HTTPS)**:
1. Creating Deployment: **Don't setup encryption on first deployment**
2. Create your user by accessing http://your-typemill.example.com/setup
3. In Backend: Navigate to Settings -> System -> Scroll down to bottom -> And check the setting "Use X-Forwarded Headers" under "Proxy"-Section
4. No you can upgrade your deployment using TLS encryption
5. That's it, you can now setup your typemill instance

> **If you want to move your existing installation**:
1. Take a look at the "Migrate" section.

### Set container timezone
In most cases the the clock in the pod is not correct because of the wrong default timezone. 
This can cause application erros or application misbehaving.
You can easily change it by setting your tmezone.
In the following list you can find valid settings. [See here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List)
```
typemill:
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
    - host: my-typemill.example.org #<--- Just an example. Use your domainname.
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
    - host: my-typemill.example.org #<--- Just an example. Use your domainname.
      paths:
        - path: /
          pathType: ImplementationSpecific
    tls:
    - secretName: my-typemill-ssl-secret
      hosts:
      - my-typemill.example.org #<--- Just an example. Use your domainname.
```
**Create SSL Certificate secret:**
```
apiVersion: v1
kind: Secret
metadata:
  name: my-typemill-ssl-secret
  namespace: <Typemill APP NAMESPACE>
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
    - host: my-typemill.example.org #<--- Just an example. Use your domainname.
      paths:
        - path: /
          pathType: ImplementationSpecific
    tls:
    - secretName: my-typemill-ssl-secret
      hosts:
      - my-typemill.example.org #<--- Just an example. Use your domainname.
```
#### PHP INI Settings
This chart allows you to adapt you php ini config.
Per default the following values are set in the **php_ini_config** section in your values.yaml:
```
recommended.ini: |
    upload_max_filesize = 100M
    post_max_size = 100M
    max_execution_time = 60
    output_buffering = on
```

You can adapt it by either editing the preconfigured **recommended.ini** setting (DO THIS WITH CAUTION!) or by adding a new file by just appending a new config:
```
recommended.ini: |
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
This chart allows you to adapt your htaccess config by simple changing the lines located at **typemill** -> **htaccess**.
> **Please be careful when making changes.**
```
htaccess: 
    My custom content
```

## Migrating
You don't need to execute the setup because you move existing user details to the new instance.
Create a backup of your existing **"settings"**, **"content"**, **"media"**, **"plugins"**, **"themes"** and **"plugins"** directory, move into the PV of the new typemill deployment.
If you want to setup your deployment with tls encryption (HTTPS) **behind a proxy** you need to edit the settings.yaml (settings/settings.yaml) and change **proxy: false** to **proxy: true**.

## Installing Plugins and Themes
Go to [Typemill Plugins Page](https://plugins.typemill.net/) or [Typemill Themes Page](https://themes.typemill.net/) and note down or remeber the plugin names located on top of every plugin's tile. Just edit your values.yaml in the section "typemill" and add the plugins you want to install to the key "install_plugins" => "plugin_names" or "install_themes" => "theme_names". An example can be found some lines below.

## Feature missing or bug found
Please tell me by open a github issue: [oleds-helm-charts](https://github.com/OLED1/oleds-helm-charts).

## Whats new?
### Chart Version 0.1.3 (0.1.3-dev11)
- Updated App version to typemill 1.5.3.4.
- It's now possible to configure most of the needed settings in the "Visual editor" of kubeapps.
> NOTE: Due to wrong list generation of the plugin_names and themes_names section in the Visual editor, they must be added "manually" in the yaml file.

### Chart Version 0.1.4 (0.1.41-dev) - 20.12.2022
- Added the ability to setup pod timezone
- Added the ability to change php.ini-config values

## FAQ
If you have a feature request or found a bug, open a github issue [here](https://github.com/OLED1/oleds-helm-charts).
There are currently no open questions. You ask me, I will answer ;)
