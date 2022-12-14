<?php
#CMS - CMS Made Simple
#(c)2004 by Ted Kulp (wishy@users.sf.net)
#Visit our homepage at: http://www.cmsmadesimple.org
#
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#$Id: editgroup.php 11053 2017-02-04 04:20:03Z calguy1000 $

$CMS_ADMIN_PAGE=1;

require_once("../lib/include.php");
require_once("../lib/classes/class.group.inc.php");
$urlext='?'.CMS_SECURE_PARAM_NAME.'='.$_SESSION[CMS_USER_KEY];

check_login();

$gCms = cmsms();
$db = $gCms->GetDb();

$error = "";

$dropdown = "";

$group = "";
if (isset($_POST["group"])) $group = cleanValue($_POST["group"]);

$description = "";
if (isset($_POST["description"])) $description = cleanValue($_POST["description"]);

$group_id = -1;
if (isset($_POST["group_id"])) $group_id = (int) $_POST["group_id"];
else if (isset($_GET["group_id"])) $group_id = (int) $_GET["group_id"];

$active = 1;
if (!isset($_POST["active"]) && isset($_POST["editgroup"]) && $group_id != 1) $active = 0;

if (isset($_POST["cancel"])) {
	redirect("listgroups.php".$urlext);
	return;
}

$userid = get_userid();
$access = check_permission($userid, 'Manage Groups');
$userops = $gCms->GetUserOperations();
$useringroup = $userops->UserInGroup($userid,$group_id);

if ($access) {
    $groupobj = new Group;
    if( $group_id > 0 ) {
        $groupobj = Group::load($group_id);
    }
    if (isset($_POST["editgroup"])) {
        $validinfo = true;
        if ($group == "") {
            $validinfo = false;
            $error .= "<li>".lang('nofieldgiven', array(lang('groupname')))."</li>";
        }

        if ($validinfo) {
            $groupobj->name = $group;
            $groupobj->description = $description;
            $groupobj->active = $active;
            \CMSMS\HookManager::do_hook('Core::EditGroupPre', [ 'group'=>&$groupobj ] );

            $result = $groupobj->save();
            if ($result) {
                \CMSMS\HookManager::do_hook('Core::EditGroupPost', [ 'group'=>&$groupobj ] );

                // put mention into the admin log
                audit($groupobj->id, 'Admin User Group: '.$groupobj->name, 'Edited');
                redirect("listgroups.php".$urlext);
                return;
            }
            else {
                $error .= "<li>".lang('errorupdatinggroup')."</li>";
            }
        }

    }
    else if ($group_id != -1) {
        $group = $groupobj->name;
        $description = $groupobj->description;
        $active = $groupobj->active;
    }
}

if (strlen($group) > 0) $CMS_ADMIN_SUBTITLE = $group;
include_once("header.php");

if (!$access) {
  echo "<div class=\"pageerrorcontainer\"><p class=\"pageerror\">".lang('noaccessto', array(lang('editgroup')))."</p></div>";
}
else {
  if ($error != "") {
    echo "<div class=\"pageerrorcontainer\"><ul class=\"pageerror\">".$error."</ul></div>";
  }
?>

<div class="pagecontainer">
	<?php echo $themeObject->ShowHeader('editgroup'); ?>
	<form method="post" action="editgroup.php">
        <div>
          <input type="hidden" name="<?php echo CMS_SECURE_PARAM_NAME ?>" value="<?php echo $_SESSION[CMS_USER_KEY] ?>" />
        </div>
	<div class="pageoverflow">
	  <p class="pagetext"><label for="groupname"><?php echo lang('name')?>:</label></p>
 	  <p class="pageinput"><input type="text" id="groupname" name="group" maxlength="25" value="<?php echo $group?>" /></p>
        </div>
	<div class="pageoverflow">
	  <p class="pagetext"><label for="description"><?php echo lang('description')?>:</label></p>
 	  <p class="pageinput"><input type="text" id="description" name="description" size="80" maxlength="255" value="<?php echo $description?>" /></p>
        </div>
	<?php if( !$useringroup && ($group_id != 1) ) { ?>
	  <div class="pageoverflow">
	    <p class="pagetext"><label for="active"><?php echo lang('active')?>:</label></p>
	    <p class="pageinput"><input type="checkbox" id="active" name="active" <?php echo ($active == 1?"checked=\"checked\"":"")?> /></p>
	  </div>
 	   <?php } else { ?>
                <div><input type="hidden" name="active" value="<?php echo $active ?>"/></div>
           <?php } ?>
		<div class="pageoverflow">
			<p class="pagetext">&nbsp;</p>
			<p class="pageinput">
				<input type="hidden" name="group_id" value="<?php echo $group_id?>" /><input type="hidden" name="editgroup" value="true" />
				<input type="submit" value="<?php echo lang('submit')?>" class="pagebutton" />
				<input type="submit" name="cancel" value="<?php echo lang('cancel')?>" class="pagebutton" />
			</p>
		</div>
	</form>
</div>
<?php

}

include_once("footer.php");


?>
