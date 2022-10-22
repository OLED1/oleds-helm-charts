<?php
# CMS Made Simple Configuration File
# Documentation: https://docs.cmsmadesimple.org/configuration/config-file/config-reference
#
$config['dbms'] = 'mysqli';
$config['db_hostname'] = getenv("CMSMS_HOST");
$config['db_username'] = getenv("CMSMS_USER");
$config['db_password'] = getenv("CMSMS_USER_PW");
$config['db_name'] = getenv("CMSMS_DB");
$config['db_prefix'] = getenv("CMSMS_DB_PREFIX");
$config['timezone'] = 'UTC';
$config['url_rewriting'] = 'mod_rewrite';
$config['root_url'] = 'https://cms-made-simple-kube.edtmair.at';
?>