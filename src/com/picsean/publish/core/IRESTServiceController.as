package com.picsean.publish.core
{
	public interface IRESTServiceController
	{
		 function initService():void;
		 function doLogin(user_name:String, password:String):void;
		 function getMagazines(pubid : String):void;
		 function getEditions(pubid:String, magid:String):void;
	}
}