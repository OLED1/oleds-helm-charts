# Typemill helm chart

> **This Helm chart is a custom helm chart packaged by OLED1**.
> There is no official support from typemill itself.

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

## Migrating
Create a backup of your existing "content" and "media" directory, move into the PV of the new typemill deployment.

## Installing Plugins
Go to [Typemill Plugins Page](https://plugins.typemill.net/) and note down or remeber the plugin names located on top of every plugin's tile. Just edit your values.yaml in the section "typemill" and add the plugins you want to install to the key "install_plugins" => "plugin_names". An example can be found some lines below.
