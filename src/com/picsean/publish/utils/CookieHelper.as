package com.picsean.publish.utils
{
	import flash.net.SharedObject;
	
	public class CookieHelper 
	{
		private static var _instance:CookieHelper;
		private var so:SharedObject;
		
		public static function getInstance():CookieHelper    {
			if(_instance == null)    {
				_instance = new CookieHelper();
			}
			return _instance;
		}
		
		public function initialize():Boolean {
			this.so = SharedObject.getLocal("PicseanPublishPlus");
			if(so.data.userInfo == null)    {
				so.data.userInfo = ""
				so.data.workspace = ""
				return false;
			}
			else    {
				return true;
			}
		}
		
		public function getUserInfo():Object    {
			return so.data.userInfo as Object;
		}
		public function addUserInfo(pos:Object):void    {
			this.so.data.userInfo = pos;
		}
		public function setWorkspace(s:String):void	{
			so.data.workspace = s;
			this.so.data.userInfo.workspace = s;
		}
		public function getWorkspace():String    {
			return so.data.workspace;
		}
	}
	
}