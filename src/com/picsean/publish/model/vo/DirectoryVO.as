package com.picsean.publish.model.vo
{
	import com.adobe.utils.DateUtil;
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;

	public class DirectoryVO
	{
		public var url:String;
		public var type:String;
		public var id:int;
		public var fileVO:FileVO;
		public var tobePublish : Boolean = false;
		public var timeDiff : Object
		public var selectedDevice:String
		
		public function DirectoryVO(durl:String,dtype:String,dirid:int,selectedDevice:String)
		{
			this.url = durl;
			this.type = dtype;
			this.id = dirid;
			timeDiff = new Object();
			this.selectedDevice = selectedDevice;
			this.tobePublish = tobePublished();
		}
		
		public function getArticleFileName():String	{
			return this.url  + this.url.substring(this.url.lastIndexOf(File.separator)) + Configuration.INDD;
		}
		public function getArticleInfoPrint():String	{
			var fileName :String =  this.url  + this.url.substring(this.url.lastIndexOf(File.separator)) + Configuration.INDD;
			fileName = "..."+fileName.substring(fileName.length-20, fileName.length);
			return fileName;
		}
		
		public function getJsonFileName():String	{
			
			if(this.selectedDevice == Configuration.DEVICE_IPAD_RETINA)	{
				return changeJsonDirectoryRetina() +  File.separator +"p01.json";
			}
			return this.url + File.separator +"p01.json";
		}
		
		public function getTimeInfo():String	{
			return   "    " +(timeDiff.idml - timeDiff.json);
		}

		
		private function tobePublished():Boolean	{
			var f_idml:File = new File(getArticleFileName());
			var f_json:File = new File(getJsonFileName());
			var tobe : Boolean = true;
		
			if(f_json.exists)	{
				timeDiff.idml = f_idml.modificationDate.getTime();
				timeDiff.json = f_json.modificationDate.getTime();
				timeDiff.txt = "JSON  "+f_json.modificationDate+"    IDML    "+f_idml.modificationDate;
				// idml has to be on the highside
				//if( (timeDiff.idml - timeDiff.json) > 2000 )	{
					//tobe = false;
				//}
				tobe = ((timeDiff.idml - timeDiff.json) > 2000 ? true : false)
			}
			return tobe;
		}
		public function getFileId():String	{
			return File.separator + this.type +  this.url.substring(this.url.lastIndexOf( File.separator ) );
		}
		
		private function changeJsonDirectoryRetina():String	{
			var jsonUrl : String = this.url.substring(0, url.indexOf( File.separator + this.type + File.separator));
			return jsonUrl +   Configuration.IPAD_RETINA_LITERAL_PUBLISH + this.url.substring (url.indexOf( File.separator + this.type + File.separator))
		}
	}
}