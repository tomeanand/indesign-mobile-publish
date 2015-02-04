package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.PageItem;
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;


	public class PropertyWrapper
	{
		

		public function PropertyWrapper()
		{
		}
		
		
		public static function wrapTimer(feature:Object, delay:String):Object
		{
			var _subArray:Array = new Array();
			_subArray.push(feature);
			var _json:Object = new Object();
			_json.type = Configuration.TYPE_TIMERJSON;
			_json.subfeatures = _subArray;
			_json.orientation = feature.orientation;
			_json.delay = delay;
			return _json; 
		}
		
		public static function wrapAnimated(feature:Object,item:PageItem, pageDir:File,serverPath:String):Object
		{
			var buttonImage:PageItem = item;
			var exportFile:File = new File(pageDir.url+File.separator+"animatedButton.png");
			var buttonImageURL:String = serverPath+"animatedButton.png";
			buttonImage.exportFile(ExportFormat.PNG_FORMAT,exportFile);
			var _json:Object = feature;
			_json.subtype = _json.type;
			_json.type = Configuration.TYPE_ANIMBTN;
			_json.buttonimage = buttonImageURL;
			
			return _json; 
		}
	}
}