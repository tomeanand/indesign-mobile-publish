package com.picsean.publish.automation.queue
{
	
	import com.picsean.publish.utils.Configuration;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	import org.osmf.logging.Log;

	
	public class LoadAndResizeImageOperation extends Operation	{
	private var _imageUrl:String;
	private var _size:Object;
	
	private var _loader:Loader;
	
	public function LoadAndResizeImageOperation(imageUrl:String, size:Number)
	{
		super();
		
		_imageUrl = imageUrl;
		//_size = size;
		Log.getLogger(Configuration.PICSAEN_LOG).info(size+" +++++  .."+_imageUrl.substring(_imageUrl.length-30))
		_loader = new Loader();
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
		_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
	}

	
	override protected function performOperation():void
	{
		_loader.load(new URLRequest(_imageUrl));
	}
	
	private function resizeImage(image:BitmapData):BitmapData
	{
		var newWidth:Number = image.width /2; //_size.w;
			var newHeight:Number = image.height/2 //_size.h;
				var transformation:Matrix = new Matrix();
				transformation.scale(0.5,0.5);
					
					var resized:BitmapData = new BitmapData(newWidth, newHeight);
		resized.draw(image, transformation);
		return resized;
	}
	
	private function handleLoaderComplete(event:Event):void
	{
		result('done');
		//result(resizeImage((_loader.content as Bitmap).bitmapData));
	}
	
	private function handleLoaderError(event:IOErrorEvent):void
	{
		fault('fail');
//		fault(event);
	}
	}
}