package com.picsean.publish.automation
{
	
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	import com.picsean.publish.utils.Configuration;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	import mx.states.AddChild;
	
	import org.osmf.logging.Log;
	
	public class ImageScale extends UIComponent
	{
		private var file:File; 
		private var fileStr:FileStream;
		private var imgdata:ByteArray;
		private var jpg:mx.controls.Image;
		private var newimage:BitmapData;
		private var idCount:int=0;
		private var resultArray :ArrayCollection;
		private var timer:Timer = new Timer(2000);
		private var _image : BitmapData;
		private var stream:FileStream
		
		//private static const TYPE_PNG :String = ".png";
		private static const TYPE_JPG :String = "jpg";
		
		
		
		public function ImageScale()
		{
			
		}
		public function scaleImages(arr:ArrayCollection):void{
			/*for (var i:int=0; i < arr.length; i++){
			trace(arr[i].path);
			fileSelected(arr[i].path)
			}*/
			
			//this.jpg.visible = false;
			timer.addEventListener(TimerEvent.TIMER , activateTimer);
			Log.getLogger(Configuration.PICSAEN_LOG).info(" ................PRINTING STARTED.............. ");
			resultArray = arr
			Log.getLogger(Configuration.PICSAEN_LOG).info(" Number of file : "+ resultArray.length + " in the queue. Estimated time : "+ Math.round((resultArray.length * 1)/4) +" minutes");
			fileSelected(idCount)
		}
		
		private function fileSelected(count:int):void 
		{
			
			var filePath:String = resultArray[idCount].path
			jpg = new Image();
			this.addChild(jpg);
			//if(resultArray[idCount].extension == TYPE_JPG){
			imgdata = new ByteArray();
			stream = new FileStream();
			stream.addEventListener(Event.COMPLETE,drawImage)
			stream.addEventListener(ProgressEvent.PROGRESS,progressEvent)
			file = new File(filePath)
			stream.openAsync( file, FileMode.READ);
			/*var filePath:String = resultArray[idCount].path
			file = new File(filePath)
			var filePath:String = resultArray[idCount].path
			jpg.load(file.url);
			jpg.addEventListener(Event.COMPLETE,resize);*/
			//stream.close();
			
		}  
		private function drawImage(e:Event):void{
			
			
			stream.readBytes( imgdata);
			
			//jpg.addEventListener(
			jpg.source = imgdata;
			//this.removeChild(jpg);
			e.target.close();
			jpg.addEventListener( Event.COMPLETE, resize);
			
		}
		
		private function progressEvent(e:ProgressEvent):void{
			/*trace(e.bytesLoaded*1024 +"::::::::::::"+ e.bytesTotal*1024)
			if(e.bytesLoaded == e.bytesTotal){
				
			}*/
			//
		}
		
		private function resize(e:Event ):void
		{ 
			var m:Matrix = new Matrix();
			m.scale(0.5, 0.5);
			newimage = new BitmapData( jpg.contentWidth / 2, jpg.contentHeight / 2,true,0); 
			newimage.draw( jpg, m, null, null, null, true);
			var imgByteArray:ByteArray;
			//file = new File();
			if(file.extension == TYPE_JPG){
				var jpgenc:JPEGEncoder = new JPEGEncoder(100)
				imgByteArray = jpgenc.encode( newimage);                
				var stream2:FileStream = new FileStream();
				/*stream2.addEventListener(Event.COMPLETE, closeStream);
				stream2.addEventListener(ProgressEvent.PROGRESS,progressEvent);*/
				stream2.open(file, FileMode.WRITE);
				stream2.writeBytes( imgByteArray);
				
				stream.close();  
				//newimage.dispose();
			}else {
				var pngenc :PNGEncoder = new PNGEncoder();
				imgByteArray  = pngenc.encode(newimage);
				var stream1:FileStream = new FileStream();
				stream1.open(file, FileMode.WRITE);
				stream1.writeBytes( imgByteArray);
				//stream1.addEventListener(Event.COMPLETE, closeStream);
				//stream.close();  
				
				
			}
			timer.start()
			jpg.source = null;
			this.removeChild(jpg);
			
		}
		
		private function activateTimer(event:TimerEvent):void{
			timer.stop();
			if (idCount < resultArray.length -1){
				idCount++;
				//Log.getLogger(Configuration.PICSAEN_LOG).info(" Count " + file.name);
				fileSelected(idCount);
			}else{
				Log.getLogger(Configuration.PICSAEN_LOG).info(" .................PRINTING DONE.............. /n");
				//EventTransporter.getInstance().dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_PANO_SLICE,this))
				EventTransporter.getInstance().dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_SCALE_COMPLETED,this));
			}
		}
	}
}