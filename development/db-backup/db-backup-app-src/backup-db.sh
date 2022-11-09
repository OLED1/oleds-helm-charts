#!/bin/bash
local_dav_dir="/mnt/davs"
local_pv_dir="/mnt/pv-backup"
local_nfs_dir="/mnt/nfs-backup"
tmpdir="/tmp"
mailoutfile="mail_output"

INFO='\033[0;34m'
SUCC='\033[0;32m'
STEP='\033[1;33m'
CRIT='\033[0;31m'
NC='\033[0m'
BWhite='\033[1;37m'

execstatus=0

echo "\n" > $mailoutfile

rm -rf /tmp/*.sql.gz

(

printf "%100s\n" " " | tr ' ' '-' 
echo "${BWhite}[$(date)]${INFO}[INFO]${NC}Starting Docker/Kubernetes database dump script by ${BWhite}OLED1.${NC}"
echo "${BWhite}[$(date)]${INFO}[INFO]${NC}Found a bug or feature missing? Please get in touch with me."
echo "${BWhite}[$(date)]${INFO}[INFO]${NC}Github repository: ${BWhite}https://github.com/OLED1/oleds-helm-charts.${NC}"
printf "%100s\n" " " | tr ' ' '-' 

#################################
#       Dumping Databases       #
#################################
echo "${BWhite}[$(date)]${INFO}[INFO]${NC}The following databases will be dumped: ${DBS_TO_DUMP}."
for this_db_to_dump in $DBS_TO_DUMP;
do
    db_dump_filename="${this_db_to_dump}_$(date +"%m_%d_%Y_%H_%M_%S").sql.gz"
    db_tmp_save_dir="${tmpdir}/${db_dump_filename}"
    echo "${BWhite}[$(date)]${STEP}[STEP]${NC}Dumping database ${this_db_to_dump} to ${db_tmp_save_dir}. This can take a while. Please wait."
    mysqldump -u$DB_USER -p$DB_USER_PASSWORD -h $DB_HOST $this_db_to_dump | gzip -c > $db_tmp_save_dir
    dump_status=$?
    if [ $dump_status -eq 0 ];
    then
        echo "${BWhite}[$(date)]${SUCC}[SUCC]${NC}All worked fine. Hanging on..."
    else
        echo "${BWhite}[$(date)]${CRIT}[CRIT]${NC}That did not work as expected (Status: $dump_status)."
        execstatus=1
    fi
    sleep 1
done

if [ $execstatus -eq 0 ];then
    echo "${BWhite}[$(date)]${STEP}[STEP]${NC}Uploading/Copying files to target directories."
fi

#####################################
#       Backup to webdav share      #
#####################################
if [ $execstatus -eq 0 ];then
    if [ "${DAVBACKUPENABLED}" = "true" ];then
        printf "%100s\n" " " | tr ' ' '-' 
        echo "${BWhite}[$(date)]${STEP}[STEP]${NC}DAV backup seems to be enabled."

        for file in ${tmpdir}/*.sql.gz
        do
            echo "${BWhite}[$(date)]${INFO}[INFO]${NC}Uploading file '${file}' to '${DAVROOTDIR}${DAVBACKUPSUBDIR}'."
            httpcode=500
            httpcode=$(curl -s -w "%{http_code}" -o /dev/null -u $DAVUSER:$DAVPWD -T ${file} ${DAVROOTDIR}${DAVBACKUPSUBDIR})
            
            if [ $httpcode -eq 201 ];
            then
                echo "${BWhite}[$(date)]${SUCC}[SUCC]${NC}All worked fine (http code: $httpcode). Hanging on..."
            else
                echo "${BWhite}[$(date)]${CRIT}[CRIT]${NC}That did not work as expected (http code: $httpcode). $connection_status"
                execstatus=1
            fi
        done
    fi
fi

#############################
#       Backup to pv        #
#############################
if [ $execstatus -eq 0 ];then
    if [ "${PVBACKUPENABLED}" = "true" ] && [ $execstatus -eq 0 ];then
        printf "%100s\n" " " | tr ' ' '-' 
        backuppath="${local_pv_dir}/"
        echo "${BWhite}[$(date)]${STEP}[STEP]${NC}PV backup seems to be enabled."
        echo "${BWhite}[$(date)]${INFO}[INFO]${NC}Copying files '$(ls /tmp/ | grep sql.gz | tr '\n' ', ')' to '$backuppath'."
        mkdir -p $backuppath
        rsync -av ${tmpdir}/*.sql.gz $backuppath > /dev/null 2>&1
        copystatus=$?

        if [ $copystatus -eq 0 ];
        then
            echo "${BWhite}[$(date)]${SUCC}[SUCC]${NC}All worked fine. Hanging on..."
        else
            echo "${BWhite}[$(date)]${CRIT}[CRIT]${NC}That did not work as expected (Status: $copystatus)."
            execstatus=1
        fi
    fi
fi

#############################
#       Backup to nfs       #
#############################
if [ $execstatus -eq 0 ];then
    if [ "${NFSBACKUPENABLED}" = "true" ] && [ $execstatus -eq 0 ];then
        printf "%100s\n" " " | tr ' ' '-' 
        backuppath="${local_nfs_dir}/"
        echo "${BWhite}[$(date)]${STEP}[STEP]${NC}NFS backup seems to be enabled."
        echo "${BWhite}[$(date)]${INFO}[INFO]${NC}Copying files '$(ls /tmp/ | grep sql.gz | tr '\n' ', ')' to '$backuppath'."
        mkdir -p $backuppath
        rsync -av ${tmpdir}/*.sql.gz $backuppath > /dev/null 2>&1
        copystatus=$?

        if [ $copystatus -eq 0 ];
        then
            echo "${BWhite}[$(date)]${SUCC}[SUCC]${NC}All worked fine. Hanging on..."
        else
            echo "${BWhite}[$(date)]${CRIT}[CRIT]${NC}That did not work as expected (Status: $copystatus)."
            execstatus=1
        fi
    fi
fi

if [ $execstatus -eq 0 ];then
    status="${SUCC}[SUCC]${NC}"
    echo "${BWhite}[$(date)]${SUCC}[SUCC]All backup tasks ended successfully.${NC}"
else
    status="${CRIT}[CRIT]${NC}"
    echo "${BWhite}[$(date)]${CRIT}[CRIT]Some tasks failed.${NC}"
fi

echo "${BWhite}[$(date)]${status}Script execution ended with statucode ${execstatus}."

if [ $execstatus -eq 0 ];then
    echo "Subject:(Success)DB dump script ended ($(date))" > ${mailoutfile}.html
else
    echo "Subject:(Failed)DB dump script ended ($(date))"  > ${mailoutfile}.html
fi

) 2>&1 | tee -a $mailoutfile

#################################
#       Send status mail        #
#################################
if [ "${ENABLE_SMTP}" = "true" ];then
    echo "${BWhite}[$(date)]${SUCC}[SUCC]${NC}Sending status mail."

    echo "root=
mailhub=${SMTP_HOST}:${SMTP_PORT}
rewriteDomain=$(echo $MAIL_FROM_EMAIL | cut -d"@" -f 2)
FromLineOverride=YES
AuthUser=${SMTP_LOGIN_NAME}
AuthPass=${SMTP_LOGIN_PW}
UseTLS=${SMTP_TLS}
UseSTARTTLS=${SMTP_STARTTLS}" > /etc/ssmtp/ssmtp.conf

    echo "root:${MAIL_FROM_EMAIL}:${SMTP_HOST}:${SMTP_PORT}" > /etc/ssmtp/revaliases

    echo "Content-Type: text/html\nMime-Version: 1.0" >> ${mailoutfile}.html

    echo "\n\n$(cat $mailoutfile | aha --black)" >> ${mailoutfile}.html

    ssmtp -vvv -F"$MAIL_FROM_NAME" $RCPT_LIST < ${mailoutfile}.html
fi