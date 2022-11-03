#!/bin/bash
local_dav_dir="/mnt/davs"
local_pv_dir="/mnt/pv-backup"
tmpdir="/tmp"
mailoutfile="mail_output"

INFO='\033[0;34m'
SUCC='\033[0;32m'
STEP='\033[1;33m'
CRIT='\033[0;31m'
NC='\033[0m' # No Color
BWhite='\033[1;37m'

execstatus=0

echo "\n" > $mailoutfile

rm -rf /tmp/*.sql.gz

(
#################################
#       Dumping Databases       #
#################################
echo "${BWhite}[$(date)]${INFO}[INFO]${NC}The following databases will be dumped: ${DBS_TO_DUMP}."
for this_db_to_dump in $DBS_TO_DUMP;
do
    db_dump_filename="${this_db_to_dump}_$(date +"%m_%d_%Y_%H_%M_%S").sql.gz"
    db_tmp_save_dir="${tmpdir}/${db_dump_filename}"
    echo "${BWhite}[$(date)]${STEP}[STEP]${NC}Dumping database ${DB_HOST} to ${db_tmp_save_dir}. This can take a while. Please wait."
    mysqldump -u root -p$MYSQL_ROOT_PASSWORD -h $DB_HOST $this_db_to_dump | gzip -c > $db_tmp_save_dir
    dump_status=$?
    if [ $dump_status -eq 0 ];
    then
        echo "${BWhite}[$(date)]${SUCC}[SUCC]${NC}All worked fine. Hanging on..."
    else
        echo "${BWhite}[$(date)]${ERROR}[ERROR]${NC}That did not work as expected (Status: $dump_status)."
        execstatus=1
    fi
    sleep 1
done

#####################################
#       Backup to webdav share      #
#####################################
if [ $execstatus -eq 0 ];then
    echo "${BWhite}[$(date)]${STEP}[STEP]${NC}Uploading/Copying files to target directories."
    if [ "${DAVBACKUPENABLED}" = "true" ];then
        echo "${BWhite}[$(date)]${STEP}[STEP]${NC}DAV backup seems to be enabled."
        echo "${BWhite}[$(date)]${INFO}[INFO]${NC}Uploading files '$(ls /tmp/ | grep sql.gz | tr '\n' ', ')' to '${DAVROOTDIR}${DAVBACKUPSUBDIR}'."

        for file in ${tmpdir}/*.sql.gz
        do
            echo "${BWhite}[$(date)]${INFO}[INFO]${NC}Uploading file '${file}' to '${DAVROOTDIR}${DAVBACKUPSUBDIR}'."
            httpcode=$(curl -w "%{http_code}" --progress-bar -u $DAVUSER:$DAVPWD -T ${file} ${DAVROOTDIR}${DAVBACKUPSUBDIR} | cat)
            
            if [ $httpcode -eq 201 ];
            then
                echo "${BWhite}[$(date)]${SUCC}[SUCC]${NC}All worked fine. Hanging on..."
            else
                echo "${BWhite}[$(date)]${ERROR}[ERROR]${NC}That did not work as expected (http code: $httpcode). $connection_status"
                execstatus=1
            fi
        done
    fi
fi

#############################
#       Backup to pv        #
#############################
if [ $execstatus -eq 0 ];then
    if [ "${PVBACKUPENABLED}" = "true" ] || [ $execstatus -eq 0 ];then
        backuppath="${local_pv_dir}/"
        echo "${BWhite}[$(date)]${STEP}[STEP]${NC}PV backup seems to be enabled."
        echo "${BWhite}[$(date)]${INFO}[INFO]${NC}Copying files '$(ls /tmp/ | grep sql.gz | tr '\n' ', ')' to '$backuppath'."
        mkdir -p $backuppath
        rsync -av --progress ${tmpdir}/*.sql.gz $backuppath
        copystatus=$?

        if [ $copystatus -eq 0 ];
        then
            echo "${BWhite}[$(date)]${SUCC}[SUCC]${NC}All worked fine. Hanging on..."
        else
            echo "${BWhite}[$(date)]${ERROR}[ERROR]${NC}That did not work as expected (Status: $copystatus)."
            execstatus=1
        fi
    fi
fi

echo "${BWhite}[$(date)]${SUCC}[SUCC]${NC}Script execution ended with statucode ${execstatus}."
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

    if [ $execstatus -eq 0 ];then
        echo "Subject:(Success)DB dump script ended ($(date))" > ${mailoutfile}.html
    else
        echo "Subject:(Failed)DB dump script ended ($(date))"  > ${mailoutfile}.html
    fi
    echo "Content-Type: text/html\nMime-Version: 1.0" >> ${mailoutfile}.html

    echo "\n\n$(cat $mailoutfile | aha --black)" >> ${mailoutfile}.html

    ssmtp -vvv -F"$MAIL_FROM_NAME" $RCPT_LIST < ${mailoutfile}.html
fi