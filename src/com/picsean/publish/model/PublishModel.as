package com.picsean.publish.model
{
	import com.adobe.indesign.Application;
	import com.adobe.indesign.ArrangeBy;
	import com.picsean.publish.database.S3Database;
	import com.picsean.publish.model.vo.FileVO;
	import com.picsean.publish.model.vo.PublishVO;
	import com.picsean.publish.utils.Configuration;
	
	import mx.collections.ArrayCollection;
	
	import org.as3commons.collections.fx.LinkedMapFx;

	public class PublishModel
	{
		
		///////////////////////////////////////////
		public var directoryPath:String=''; 
		public var orientation:String;
		public var pageWidth:int;
		public var pageHeight:int;
		public var pageRatio:Number;
		public var deviceSelected : String;
		public var app:Application;
		public var directoryList : LinkedMapFx = new LinkedMapFx();
		public var pageList : LinkedMapFx = new LinkedMapFx();
		public var openDocList : LinkedMapFx = new LinkedMapFx();
		public var publishVO : PublishVO;
		public var iPadFolderPath :String; ///// for automating the images to non retina mode.
		public var panoImageList:Array = new Array();
		public var relativePanoArticleList :LinkedMapFx = new LinkedMapFx();
		
		/* only for this poc*/
		
		public var panoImagelist1 :Array = new Array();
		public var panoImagelist2 :Array = new Array();
		public var isRelativePanoPages :Boolean = false;
		public var replativePanoPO :ArrayCollection = new ArrayCollection();
		
		public var allDeviceInfo : LinkedMapFx = new LinkedMapFx();
		public var s3allDeviceInfo : LinkedMapFx = new LinkedMapFx(); // cludge - folder level reverse mapping of device info
		public var excludedDirectories : LinkedMapFx = new LinkedMapFx();
		public var corruptedFileList:Array = new Array();
		
		private var databse : S3Database;
		
		/**/
		///////////////////////////////////
		private static var instance:PublishModel;
		
		public static function getInstance():PublishModel    {
			if(instance == null)    {
				instance = new PublishModel();
			}
			return instance; 
		}
		
		public function setPublishVO(folderName:String):void	{
			this.publishVO = new PublishVO(pageHeight, pageWidth, deviceSelected, pageRatio, directoryPath, folderName);
		}
		
		public function setupPublish():void	{
			this.directoryList = new LinkedMapFx();
			this.pageList = new LinkedMapFx();
			this.openDocList = new LinkedMapFx();
			this.replativePanoPO = new ArrayCollection();
			
		}
		public function initialisePublish():void	{
			createAllDeviceInfo();
			databse = new S3Database();
			databse.initDatabase();
		}
		public function initialiseDBQuieries():void	{
			databse.runInitQueries();
		}
		public function postInitialisePublish():void	{
			excludedDirectories = new LinkedMapFx();
			corruptedFileList = new Array();
			//databse.runInitQueries();
		}
		
		public function addOpenDocList(key:String, fvo:FileVO):void	{
			openDocList.add(key,fvo);
			if(openDocList.size > 3)	{
				var fileVO:FileVO;
				var list:Array = openDocList.keysToArray();
				for(var i:Number = 0; i<2; i++)	{
					fileVO = openDocList.itemFor(list[i]);
					//fileVO.closeDocument();
					//openDocList.removeKey(list[i]);
					
				}
				trace("------------>  "+openDocList.keysToArray());
			}

		}
		
		private function createAllDeviceInfo():void	{
			var allDevice:Array = Configuration.DEVICE_INFO.concat(Configuration.ANDROID_PHONE_INFO, Configuration.ANDROID_TABLET_INFO);
			for(var i:Number = 0; i<allDevice.length; i++)	{
				allDeviceInfo.add(allDevice[i].label, allDevice[i]);
				s3allDeviceInfo.add(allDevice[i].folder, allDevice[i])
			}
		}
		
		public  function getDevicesForDeploy(list:Array):Array	{
			var device:Object;
			var name:String = "";
			var dlist : Array = new Array();
			for(var i:Number = 0; i<list.length; i++)	{
				device = this.allDeviceInfo.itemFor(list[i]);
				name = (list[i] == Configuration.DEVICE_IPAD_RETINA ?  Configuration.IPAD_RETINA_LITERAL_PUBLISH : device.folder);
				dlist.push(name);
			}
			return dlist;
		}
	}
}