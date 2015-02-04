package com.picsean.publish.core
{
	import com.picsean.publish.events.EventS3Bucket;
	import com.picsean.publish.events.EventTransporter;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.upload.JSONUploadQueue;
	import com.picsean.publish.upload.S3UploadOperation;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.DirectoryDriller;
	
	import mx.collections.ArrayCollection;
	
	import org.as3commons.collections.fx.LinkedMapFx;

	public class S3Manager
	{
		private var directoryDriller : DirectoryDriller;
		private var selectedDevices:Array;
		
		private var assetsList:LinkedMapFx;
		private var jsonList : LinkedMapFx;
		
		
		private var s3upload:S3UploadOperation;
		private var jsonUpload : JSONUploadQueue;
		
		private var model : PublishModel = PublishModel.getInstance();
		
		public var isOnlyJson : Boolean = false;
		
		public function S3Manager()
		{
			
		}
		
		public function initialise(selDevice:Array):void	{
			directoryDriller = new DirectoryDriller();
			directoryDriller.initialiseSearch();
			directoryDriller.addEventListener(EventS3Bucket.EVENT_ASSETS_SEARCH_COMPLETED, onAssetsSearchCompleted);
			
			this.selectedDevices = selDevice;
			var deviceInfo : Object;
			var hasRetina :Object = {found:false,folder:""};
			var selectedObj:Object;
			
			//see IssueDataVo
			// below iteration are nothing, but to pass the deviceInfo to directoryDriller - kludge
			
			for(var i:Number = 0; i<selDevice.length; i++)	{
				selectedObj = selDevice[i];
				
				//setting retina deviceinfo
				if(selectedObj.d == "")	{ hasRetina.folder = selectedObj.f+Configuration.IPAD_RETINA_LITERAL_PUBLISH; }
				
				if(selectedObj.d == Configuration.IPAD_RETINA_LITERAL_PUBLISH)	{
					deviceInfo = model.allDeviceInfo.itemFor(Configuration.DEVICE_IPAD_RETINA);
					hasRetina.found = true;
				}
				else	{
					deviceInfo = model.s3allDeviceInfo.itemFor(selectedObj.d);
				}
				
				directoryDriller.addDirectory( {folder:selectedObj.f, device:deviceInfo} );
				
			}
			
			if(!hasRetina.found)	{
				deviceInfo = model.allDeviceInfo.itemFor(Configuration.DEVICE_IPAD_RETINA);
				directoryDriller.addDirectory( {folder:hasRetina.folder, device:deviceInfo} );
			}
			
			/**
			 * while device coming from _device from PublishNew.mxml
			 * 
			for(var i:Number = 0; i<selDevice.length; i++)	{
				deviceInfo = model.allDeviceInfo.itemFor(selDevice[i]);
				directoryDriller.addDirectory({folder:( model.directoryPath + deviceInfo.folder), device:deviceInfo} );
			}
			 * 
			**/
			
			directoryDriller.start();
			
			
			/// upload operation for 
		}
		
		private function onAssetsSearchCompleted(event:EventS3Bucket):void	{
			assetsList = event.data.images as LinkedMapFx;
			jsonList = event.data.jsons as LinkedMapFx;
			
			s3upload = new S3UploadOperation();
			jsonUpload = new JSONUploadQueue();
			
			if(isOnlyJson)	{
				jsonUpload.initOperation(jsonList);
				jsonUpload.addEventListener(EventS3Bucket.EVENT_JSON_UPLOAD_COMPLETED,onJsonUploadComplete);
				isOnlyJson = false;
			}
			else	{
				s3upload.initOperation(assetsList);
				jsonUpload.initOperation(jsonList);
			}
			
			trace(assetsList.size)
		}
		
		private function onJsonUploadComplete(event:EventS3Bucket):void	{
			EventTransporter.getInstance().dispatchEvent(event);
			jsonUpload.removeEventListener(EventS3Bucket.EVENT_JSON_UPLOAD_COMPLETED,onJsonUploadComplete);
		}
	}
}