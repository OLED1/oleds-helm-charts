<?php
#CMS - CMS Made Simple
#(c)2004-2010 by Ted Kulp (ted@cmsmadesimple.org)
#Visit our homepage at: http://cmsmadesimple.org
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
#$Id: Link.inc.php 11199 2017-04-01 15:19:16Z calguy1000 $

/**
 * Define the link content type
 * @package CMS
 * @subpackage content_types
 * @license GPL
 */

/**
 * Implementation of the CMS Made Simple link content type
 *
 * Links are content objects that appear in navigations and implement a link to an externl
 * page or site.
 *
 * @package CMS
 * @subpackage content_types
 * @license GPL
 */
class Link extends ContentBase
{
    public function IsCopyable() { return TRUE; }
    public function IsViewable() { return FALSE; }
	public function HasSearchableContent() { return FALSE; }
    public function FriendlyName() { return lang('contenttype_redirlink'); }

    function SetProperties()
    {
		parent::SetProperties();
		$this->RemoveProperty('secure',0);
		$this->RemoveProperty('cachable',true);
		$this->AddProperty('url',3,self::TAB_MAIN,TRUE,TRUE);
    }

    function FillParams($params,$editing = false)
    {
		parent::FillParams($params,$editing);

		if (isset($params)) {
			$parameters = array('url');
			foreach ($parameters as $oneparam) {
				if (isset($params[$oneparam])) $this->SetPropertyValue($oneparam, $params[$oneparam]);
			}

			if (isset($params['file_url'])) $this->SetPropertyValue('url', $params['file_url']);
		}
    }

    function ValidateData()
    {
		$errors = parent::ValidateData();
		if( $errors === FALSE )	$errors = array();

		if ($this->GetPropertyValue('url') == '') {
			$errors[]= lang('nofieldgiven',array(lang('url')));
			$result = false;
		}

		return (count($errors) > 0?$errors:FALSE);
    }

    function TabNames()
    {
		$res = array(lang('main'));
		if( check_permission(get_userid(),'Manage All Content') ) {
			$res[] = lang('options');
		}
		return $res;
    }

    function display_single_element($one,$adding)
    {
		switch($one) {
		case 'url':
			return array(lang('url').':','<input type="text" name="url" size="80" value="'.cms_htmlentities($this->GetPropertyValue('url')).'" />');
			break;

		default:
			return parent::display_single_element($one,$adding);
		}
    }

    function EditAsArray($adding = false, $tab = 0, $showadmin = false)
    {
		switch($tab) {
		case '0':
			return $this->display_attributes($adding);
			break;
		case '1':
			return $this->display_attributes($adding,1);
			break;
		}
    }

    function GetURL($rewrite = true)
    {
		return $this->GetPropertyValue('url');
		//return cms_htmlentities($this->GetPropertyValue('url'));
    }
}

?>
