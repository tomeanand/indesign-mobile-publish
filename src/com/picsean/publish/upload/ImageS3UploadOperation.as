package com.picsean.publish.upload
{
	import com.picsean.publish.automation.queue.Operation;
	import com.picsean.publish.events.EventS3Bucket;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.IImageEncoder;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	
	public class ImageS3UploadOperation extends Operation
	{
		private var _loader : Loader
		private var operationObj:Object;
		private var file:File
		private var imageEncoder : IImageEncoder;
		private var contentType : String;
		
		private var restUpload:RESTFileUpload;
		
		private static const TYPE_JPG :String = "jpg";
		private static const CNT_TYPE_JPG :String = "image/jpeg";
		private static const CNT_TYPE_PNG :String = "image/png";
		private static const KEY_PREFIX : String = "images/"
		
		
		
		public function ImageS3UploadOperation(opObj:Object)
		{
			super();
			
			this.operationObj = opObj;
			file = opObj.file as File;
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
		}
		
		override protected function performOperation():void	{
			_loader.load(new URLRequest(file.url));
		}
		
		private function handleLoaderComplete(event:Event):void	{
			
			if(file.extension == TYPE_JPG)	{
				imageEncoder = new JPEGEncoder(72);
				contentType = CNT_TYPE_JPG
			}
			else	{
				imageEncoder = new PNGEncoder();
				contentType = CNT_TYPE_PNG;
			}
			
			var bitmap:Bitmap = _loader.content as Bitmap;
			var stream:ByteArray = imageEncoder.encode( bitmap.bitmapData );
			
			/**
			 * This can be done on a betterway
			 * */
			
			restUpload = new RESTFileUpload();
			restUpload.addEventListener(EventS3Bucket.EVENT_DROPPED_INTO_BUCKET,onDropSuccess);
			restUpload.uploadToS3({ key:KEY_PREFIX+operationObj.key, f:file.name, ctype:contentType, payload:stream});
			
			operationObj.info = "droppedintoS3";
			result( operationObj );
		}
		
		private function handleLoaderError(event:IOErrorEvent):void	{
			fault({result:'oops'});			
		}
		private function onDropSuccess(event:EventS3Bucket):void	{
			restUpload.removeEventListener(EventS3Bucket.EVENT_DROPPED_INTO_BUCKET,onDropSuccess);
			restUpload = null;
			operationObj.info = "droppedintoS3";
			result( operationObj );
		}
	}
}