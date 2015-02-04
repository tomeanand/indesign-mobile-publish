package com.picsean.publish.automation.queue
{
	import com.picsean.publish.utils.Configuration;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.IImageEncoder;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	
	import org.osmf.logging.Log;

	public class SimpleScaleOperation extends Operation
	{
		private var opData : Object;
		private var _loader:Loader;
		private var file:File;
		
		private var imageEncoder : IImageEncoder;
		private var imgByteArray : ByteArray;
		private var fileStream : FileStream;
		private var bitmapData : BitmapData;
		
		private static const TYPE_JPG :String = "jpg";
		
		public function SimpleScaleOperation(operationObj:Object)
		{
			super();
			opData = operationObj;
			file = new File(opData.path)
			
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
			
			fileStream = new FileStream();
		}
		
		override protected function performOperation():void	{
			
			_loader.load(new URLRequest(file.url));
		}
		
		private function resizeImage(image:BitmapData):BitmapData
		{

			
			var newWidth:Number = image.width / 2;
			var newHeight:Number = image.height / 2
			var transformation:Matrix = new Matrix();
			transformation.scale(0.5,0.5);
						
			var resized:BitmapData = new BitmapData(newWidth, newHeight,true,0);
			resized.draw(image, transformation,  null, null, null, true);
			return resized;
		}
		
		private function handleLoaderComplete(event:Event):void	{
			imageEncoder = (file.extension == TYPE_JPG ? new JPEGEncoder(100) : new PNGEncoder() );
			bitmapData = resizeImage((_loader.content as Bitmap).bitmapData) 
			try	{
				if(bitmapData)	{
					imgByteArray = imageEncoder.encode( bitmapData );
					
					fileStream.open(file, FileMode.WRITE);
					fileStream.writeBytes( imgByteArray);
					fileStream.close();  
				}
				
			}
			catch(exception:Error)	{
				trace(exception.message)
			}
				
			
			result( {result:'published', info:file.url,ref:this} );
		}
		private function handleLoaderError(event:IOErrorEvent):void	{
			fault({result:'oops'});			
		}
		public function releaseMemory():void	{
			file = null;
			fileStream = null;
			_loader = null;
			bitmapData = null;
		}
	}
}