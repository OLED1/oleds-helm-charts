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
Find the source of the bash script executed here: [See here](https://github.com/OLED1/oleds-helm-charts/blob/main/development/db-backup/db-backup-app-src/backup-db.sh).

## Documentation
### Features
- Currently only MYSQL database(s) can be dumped
- Dumps multiple databases in a single namespace at once (you can state only one host)
- When using an external database, you can dump multiple databases at once
- Uploads the dumps automatically to a webdav share (Tested with Nextcloud)
- Copies the dumps automatically to an existing pv or an NFS Share
- Sends an e-mail when a backup ends with details about the process

## Installation
### Gather some information
At first you need to know the following database information:
- the **Username** which is allowed to dump the database you need,
- the **Password** of this user,
- the **Database** name which should be dumped and
- the **Hostname or IP** of the database which has the information which should be dumped.

### Set the right timezone
Please set the right timezone by changing the values of **backup** -> **container** -> **timezone**. Otherwise the job might get executed too early or too late.
A list of valid values can be found [here](https://manpages.ubuntu.com/manpages/xenial/man3/DateTime::TimeZone::Catalog.3pm.html).

### Backup job execution
This kubernetes deployment follows the standard unix cron job interval contention.
```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │                                   OR sun, mon, tue, wed, thu, fri, sat
# │ │ │ │ │
# * * * * *
```
Kubernetes has a nice page created where it is described. Take a look [here](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).

Per default, this script is configured as "0 0,12 * * *". That means this script will be executred every day at 0am and 12am.

### Setup Mail notifications
This script enables you to send a status information mail about every dump execution.
Just enable mailing (**backup** -> **mail_settings -> enable: true**) and fill out the following requred information:
- SMTP service hostname
- SMTP service port
- Authentication (username and password)
- Encryption (SSL and/or TLS)
- Mail recepient list

Example config:
```
mail_settings:
    ## Enable notfication via mail
    enable: true

    host_setting:
        ## SMTP Host
        host: smtp.my-host.example.com
        ## SMTP Port
        port: 465

    auth:
        ## Set to true when smtp needs authentication (recommended)
        enabled: true
        ## SMTP Username
        username: auto-backup-tool@example.com ## SMTP Password

        password: usALDE0OrdUwZ5t7F9TREsPuOg 
        
        ## Set to yes when host supports tls for encryption
        tls_encryption: true
        ## Set to yes when host supports starttls as encryption
        starttls_encryption: false

        existingSecret:
            enabled: false
            #secretName: nameofsecret
            #usernameKey: username
            #passwordKey: password

    resend_on_error:
        ## How often should the script try to resend the backup status mail
        smtp_max_retries: 2
        ## The interval in seconds between the send retries
        smtp_retry_timeout: 2

    mail_details:
        ## It's used to be able to differ from which instance the backup notification is comming from
        ## E.g. Nextcloud Productive Instance, Wordpress Test Instance, and so on ...
        ## Will be shown as follows: "My Super Important Productive Instance" <my-instance@example.com>
        mail_from: My Super Important Productive Instance
        ## From which e-mail is the notification comming from
        mail_from_email: my-instance@example.com
        ## Who should get the notification mail
        ## State mails comma seperated
        ## E.g. e-mail1, e-mail2, e-mail3, ...
        mail_recepient_list: it-s-me@example.com

        #mail_recepient_list: e-mail1@example.com, e-mail2@example.com, e-mail3@example.com
```

### Webdav share setup
To setup a DAV share you need to have the following required information by your hand:
- Webdav host (e.g. a Nextcloud instance)
- A directory where you want to put your dumps (e.g. /Backups/My-Instance-Backup/)
- Username who is allowed to access your intance
- Password of this user

Example Config:
```
  webdav:
    ## If you want to upload you database backup to a webdav share
    ## set 'enabled' to true
    enabled: true
    ## Set the root directory of your webdav share including the domain part
    ## For nextcloud it would be: https://my-nextcloud.example.com/remote.php/dav/files/<USER>/
    webdav_root: https://my-nextcloud.example.com/remote.php/dav/files/Username/
    ## The subdirectory (above the root directoy) where the backups finally should be placed
    ## NOTE: The subdirectory must exist!
    subdirectory: /My/Subdir/For/Backups/
    ## Configure Webdav authentication here
    auth:
      ## The webdav login user
      webdav_user: Username
      ## The password to you webdav
      ## NOTE: If you are using nextcloud with a second factor, create a login key first in your security settings
      webdav_user_password: VEm0N-F5JfO-hKRJd-j33G6-0a9e9

      ## If theres already an existing secret with you webdav credentials you set it up here
      ## You can leave webdav_user and webdav_user_password blank
      existingSecret:
        enabled: false
        #secretName: nameofsecret
        #usernameKey: username
        #passwordKey: password

        ## Move your database backup to an existing persistent volume
        ## NOTE: An existing share is required
```

### Existing PV setup
**I do not recommend to use this setting because PV's can easily be deleted. So use with caution.**
You just need to enable this tpye and state your existing claim.

### NFS share setup
Example config:
```
  nfs:
    ## If you want to move your database backup to a nfs share
    ## set 'enabled' to true
    enabled: enabled
    ## Hostname or IP of your NFS Server
    nfs_host: my-nfs.example.com
    ## Full path of your NFS share
    nfs_path: /my/subdir/for/backups/
```

## Feature missing or bug found
Please tell me by open a github issue: [oleds-helm-charts](https://github.com/OLED1/oleds-helm-charts).

## Whats new?
### Chart Version 0.1.0 (0.1.13-dev) - 16.12.22
- First version of the tool
- Supports only MySQL/MariaDB dumping
- See further features in the "features" section

## FAQ
If you have a feature request or found a bug, open a github issue [here](https://github.com/OLED1/oleds-helm-charts).
There are currently no open questions. You ask me, I will answer ;)
