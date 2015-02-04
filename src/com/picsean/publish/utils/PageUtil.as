package com.picsean.publish.utils
{
	import com.adobe.indesign.PageItem;
	import com.adobe.indesign.TextFrame;
	import com.adobe.indesign.TextFrames;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.PublishModel;
	
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;

	public class PageUtil
	{
		private static const TYPE:String = 'type';
		
		//private  static var _model:PublishModel = PublishModel.getInstance();
		public function PageUtil()
		{
		}
		
		
		public static function setOrientationType(type:String):String{
			if(type =='l') return 'landscape'
			else if (type == 'p') return 'portrait';
			return null
		}
		
		public static function getPublishServerURI(str:String):String	{
			var path_break:Array = str.split(File.separator);
			var serverUri:String = Configuration.PICSEAN_SERVER_URL + "/"+
				//path_break[path_break.length-7] + File.separator + 
				path_break[path_break.length-6] + File.separator + 
				path_break[path_break.length-5] + File.separator +
				path_break[path_break.length-4] + File.separator+
				path_break[path_break.length-3] + File.separator+
				path_break[path_break.length-2] + File.separator;
			
			return serverUri;
		}
		public static function getPublishServerAudioURI(str:String):String	{
			var path_break:Array = str.split(File.separator);
			var serverUri:String = Configuration.PICSEAN_SERVER_URL + "/"+
				//path_break[path_break.length-7] + File.separator + 
				path_break[path_break.length-6] + File.separator + 
				path_break[path_break.length-5] + File.separator +
				path_break[path_break.length-4] + File.separator+
				path_break[path_break.length-3] + File.separator+
				path_break[path_break.length-2] + File.separator;
			
			return serverUri;
		}
		
	}
}