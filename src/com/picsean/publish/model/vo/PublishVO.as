package com.picsean.publish.model.vo
{
	import com.picsean.publish.utils.Configuration;

	public class PublishVO
	{
		public var height : Number;
		public var width :Number;
		public var device : String;
		public var directory : String;
		public var ratio : Number;
		
		private var folderName : String;
		public var publishPath : String;
		
		public function PublishVO(pageHeight : Number, pageWidth : Number, selectedDevice : String, selectedRatio : Number, selectedDirectory : String, fname : String)
		{
			this.height = pageHeight;
			this.width = pageWidth;
			this.device = selectedDevice;
			this.ratio = selectedRatio;
			this.directory = selectedDirectory;
			this.folderName = fname;
			this.directory = changeDeviceDirectory();
			this.publishPath = this.directory;
			if(this.device == Configuration.DEVICE_IPAD_RETINA)	{
				this.publishPath = this.directory + Configuration.IPAD_RETINA_LITERAL_PUBLISH;
			}
			
		}
		
		public function toString():String	{
			return "{ HEIGHT }"+this.height+"{ WIDTH }"+this.width+"{ RATIO }"+this.ratio+"{ DEVICE }"+this.device+"{ DIRECTORY }"+this.directory
		}
		
		private function changeDeviceDirectory():String	{
			var folder : String, dirStr : String, devieStr : String;
			dirStr = this.directory.substring(this.directory.lastIndexOf("_"));
			var isDevice : Object = checkFolderContainsDevice();
			
			if(isDevice.result)	{
				return this.directory.replace(dirStr,folderName);
			}
			else	{
				if(this.folderName == "")	{
					return this.directory;
				}
				else	{
					if(!isNaN(Number( dirStr.substring(1) )))	{
						return this.directory					
					}
					else	{
						return this.directory+this.folderName;
					}
				}
			}
			
		}
		private function checkFolderContainsDevice():Object	{
			var dirStr : String = this.directory.substring(this.directory.lastIndexOf("_"));
			for(var i:Number = 0; i<Configuration.PUBLISH_SELECTABLE_FOLDERS.length; i++)	{
				if(dirStr == Configuration.PUBLISH_SELECTABLE_FOLDERS[i])	{
					return {result:true, device : Configuration.PUBLISH_SELECTABLE_FOLDERS[i]}
				}
			}
			return {result:false};	
		}
	}
}