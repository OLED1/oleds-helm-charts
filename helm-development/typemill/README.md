# Typemill helm chart

> **This Helm chart is a custom helm chart packaged by OLED1**.
> There is no official support from typemill itself.
> Active unofficial supported chart. If a new version will be released a new updated package will be created.

## Prerequisites
- Kubernetes installed
- Helm installed and configured
- (Optional) Kubeapps (Helm GUI) installed (https://tanzu.vmware.com/developer/guides/kubeapps-gs/)

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

## Migrating
You don't need to execute the setup because you move existing user details to the new instance.
Create a backup of your existing **"settings"**, **"content"**, **"media"**, **"plugins"**, **"themes"** and **"plugins"** directory, move into the PV of the new typemill deployment.
If you want to setup your deployment with tls encryption (HTTPS) **behind a proxy** you need to edit the settings.yaml (settings/settings.yaml) and change **proxy: false** to **proxy: true**.

## Installing Plugins and Themes
Go to [Typemill Plugins Page](https://plugins.typemill.net/) or [Typemill Themes Page](https://themes.typemill.net/) and note down or remeber the plugin names located on top of every plugin's tile. Just edit your values.yaml in the section "typemill" and add the plugins you want to install to the key "install_plugins" => "plugin_names" or "install_themes" => "theme_names". An example can be found some lines below.

## Feature missing or bug found
Please tell me by open a github issue: [oleds-helm-charts](https://github.com/OLED1/oleds-helm-charts).

## Whats new?
### Chart Version 0.1.3
- Updated App version to typemill 1.5.3.4.
- It's now possible to configure most of the needed settings in the "Visual editor" of kubeapps.
> NOTE: Due to wrong list generation of the plugin_names and themes_names section in the Visual editor, they must be added "manually" in the yaml file.

## FAQ
If you have a feature request or found a bug, open a github issue [here](https://github.com/OLED1/oleds-helm-charts).
There are currently no open questions. You ask me, I will answer ;)
