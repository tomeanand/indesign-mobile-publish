package com.picsean.publish.logging
{
	import flash.external.HostObject;

	public class NativeAlert
	{
		public function NativeAlert()
		{
		}
		public static function show(message:String="this is an alert"):void{
			var jInterface:HostObject = HostObject.getRoot(HostObject.extensions[0]); 
			jInterface.eval("alert('"+message+"');");
		}
	}
}