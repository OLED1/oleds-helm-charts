<?php
    $db = getenv("CMSMS_DB");
    $host = getenv("CMSMS_HOST");
    $user = getenv("CMSMS_USER");
    $user_pass = getenv("CMSMS_USER_PW");
    $root_pass = getenv("MYSQL_ROOT_PASSWORD");


    echo "[STEP]Waiting for database to come online:";
    $db_con_succ = false;
    while(!$db_con_succ){
        echo ".";
        try{
            $dbh = new PDO("mysql:host=$host", "root", $root_pass);
            $db_con_succ = true;
        }catch(Exception $e){
            sleep(1);
            continue;
        }
    }
    
    try{ 
        echo "\n[STEP]Starting migration using following parameters:\n  [INFO]{$db} {$host} {$user} {$user_pass} {$root_pass}\n";

        $stmt = $dbh->prepare("SHOW DATABASES LIKE '$db'");
        $stmt->execute();
        if($stmt->fetch(PDO::FETCH_ASSOC)){
            echo "  [INFO]Database $db is existing or installation should be skipped. Skipping some steps.\n";
        }else{
            echo "  [INFO]Database $db is not existing and first installation steps should be executed.\n";
            echo "  [EXEC]Executing: CREATE DATABASE IF NOT EXISTS `$db`; FLUSH PRIVILEGES;\n";
            $dbh->exec("CREATE DATABASE IF NOT EXISTS `$db`; FLUSH PRIVILEGES;");
    
            echo "  [EXEC]Executing: CREATE USER IF NOT EXISTS '$user'@'%' IDENTIFIED BY '$user_pass';\n";
            $dbh->exec("CREATE USER IF NOT EXISTS '$user'@'%' IDENTIFIED BY '$user_pass';");
    
            echo "  [EXEC]Executing: GRANT ALL PRIVILEGES ON $db.* TO '$user'@'%'; FLUSH PRIVILEGES;\n";
            $dbh->exec("GRANT ALL PRIVILEGES ON $db.* TO '$user'@'%'; FLUSH PRIVILEGES;");
    
            $dbh = new PDO("mysql:host=$host;dbname=$db", "$user", $user_pass);
            
            echo "[STEP]Installing example database.\n";
            prepareAndExecuteMYSQLStatements(__DIR__ . "/cmsms_app_full.sql", $dbh);
    
            echo "[STEP]Inserting user data.\n";
    
            $username = getenv("CMSMS_APP_ADMIN_USERNAME");
            $password = getenv("CMSMS_APP_ADMIN_PASSWORD");
            $email_address = getenv("CMSMS_APP_ADMIN_EMAIL");
    
            echo "  [INFO]Username: $username\n";
            echo "  [INFO]Password: $password\n";
            echo "  [INFO]E-Mail: $email_address\n";
    
            $salt = substr(str_shuffle(md5(realpath(getcwd())).time()),0,16);
            $salted_password = md5($salt.$password);
            $now = new DateTime();
            $now_formatted = $now->format("Y-m-d H:i:s");
    
            echo "  [EXEC]Executing: DELETE FROM `cms_users` WHERE user_id = 1;\n";
            $dbh->exec("DELETE FROM `cms_users` WHERE user_id = 1");
    
            echo "  [EXEC]Executing: INSERT INTO `cms_users` VALUES (1,$username,$salted_password,1,'','',$email_address,1,$now_formatted,$now_formatted);\n";
            $dbh->exec("INSERT INTO `cms_users` VALUES (1,'$username','$salted_password',1,'','','$email_address',1,'$now_formatted','$now_formatted')");
    
            echo "  [EXEC]Executing: UPDATE `cms_siteprefs` SET sitepref_value = $salt WHERE sitepref_name = 'sitemask';\n";
            $dbh->exec("UPDATE `cms_siteprefs` SET sitepref_value = '$salt' WHERE sitepref_name = 'sitemask';");
    
            echo "[STEP]Setting up e-mail sttings if configured in env's and not existings.\n";
            $stmt = $dbh->prepare("SELECT COUNT(*) AS count FROM `cms_siteprefs` WHERE sitepref_name = 'mailprefs'");
            $stmt->execute();
            $mailsettings_count = $stmt->fetch(PDO::FETCH_ASSOC)["count"];
            if($mailsettings_count == 0 && filter_var(getenv("CMSMS_SMTP_PRECONFIGURE"), FILTER_VALIDATE_BOOLEAN)){
                $smtp_host = getenv("CMSMS_SMTP_HOST");
                $smtp_port = getenv("CMSMS_SMTP_PORT");
                $smtp_from = getenv("CMSMS_SMTP_FROM");
                $smtp_sendername = getenv("CMSMS_SMTP_SENDERRNAME");
                $smtp_auth_needed = (int)filter_var(getenv("CMSMS_SMTP_AUTH_NEEDED"), FILTER_VALIDATE_BOOLEAN);
                $smtp_auth_user = getenv("CMSMS_SMTP_AUTH_USER");
                $smtp_auth_pw = getenv("CMSMS_SMTP_AUTH_PW");
                $smtp_encryption = (getenv("CMSMS_SMTP_AUTH_ENCRYPTION") == "none" ? "" : getenv("CMSMS_SMTP_AUTH_ENCRYPTION"));
    
                $mailprefs_preformat = 'a:12:{s:6:\"mailer\";s:4:\"smtp\";s:4:\"host\";s:' . strlen($smtp_host) . ':\"' . $smtp_host . '\";s:4:\"port\";s:' . strlen($smtp_port) . ':\"' . $smtp_port . '\";s:4:\"from\";s:' . strlen($smtp_from) . ':\"' . $smtp_from . '\";s:8:\"fromuser\";s:' . strlen($smtp_sendername) . ':\"' . $smtp_sendername . '\";s:8:\"sendmail\";s:18:\"/usr/sbin/sendmail\";s:8:\"smtpauth\";s:1:\"' . $smtp_auth_needed . '\";s:8:\"username\";s:' . strlen($smtp_auth_user) . ':\"' . $smtp_auth_user . '\";s:8:\"password\";s:' . strlen($smtp_auth_pw) . ':\"' . $smtp_auth_pw . '\";s:6:\"secure\";s:' . strlen($smtp_encryption) . ':\"' . $smtp_encryption . '\";s:7:\"timeout\";s:2:\"60\";s:7:\"charset\";s:5:\"utf-8\";}';
    
                echo "  [INFO]Setting UP Mail Account using the following values:\n";
                echo "  [INFO]Host: {$smtp_host}, PORT: {$smtp_port}, FROM: {$smtp_from}, SENDERNAME: {$smtp_sendername}, SMTPNEEDAUTH: {$smtp_auth_needed}, AUTHUSER: {$smtp_auth_user}, AUTHPASSWD: {$smtp_auth_pw}, ENCRYPTION: {$smtp_encryption}\n";            
                echo "  [EXEC]Executing: INSERT INTO `cms_siteprefs` VALUES ('mailprefs','{$mailprefs_preformat}',NULL,NULL);\n";
                $dbh->exec("INSERT INTO `cms_siteprefs` VALUES ('mailprefs','{$mailprefs_preformat}',NULL,NULL);");
            }else{
                echo "  [SKIP]Mail settings are currently existing in database or not stated in the env's. Skipping.\n";
                echo "  [INFO]DB Exists: {$mailsettings_count}, PRECONFIG: " . getenv("CMSMS_SMTP_PRECONFIGURE") . "\n";
            }
        }

    }catch(Exception $e){
        print_r($e);
    }

    function prepareAndExecuteMYSQLStatements(string $fileToLoad, object $dbh){
        // Temporary variable, used to store current query
        $templine = '';
        // Read in entire file
        $lines = file($fileToLoad);
        // Loop through each line
        foreach ($lines as $line)
        {
            // Skip it if it's a comment
            if (substr($line, 0, 2) == '--' || $line == '' || substr($line, 0, 3) == '/*!')
                continue;

            // Add this line to the current segment
            $templine .= $line;
            // If it has a semicolon at the end, it's the end of the query
            if (substr(trim($line), -1, 1) == ';')
            {
                // Perform the query
                
                echo "  [EXEC]Executing: {$templine}";
                $dbh->exec($templine)/* or print('Error performing query. <strong>' . $templine . ': <br />')*/;
                //print_r($dbh->errorInfo());

                // Reset temp variable to empty
                $templine = '';
            }
        }
    }
?>