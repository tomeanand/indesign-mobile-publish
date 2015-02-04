package com.picsean.publish.automation
{
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.utils.Configuration;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.controls.Image;
	import mx.graphics.codec.JPEGEncoder;
	
	import org.as3commons.collections.utils.NumericComparator;
	import org.osmf.logging.Log;
	
	public class SplitImage extends Sprite
	{
		
		private var file:File; 
		private var fileStr:FileStream;
		private var jpgdata:ByteArray;
		private var jpg:Image;
		private var newjpg:BitmapData;
		private var timer:Timer = new Timer(1000);
		private var idCount :int =0;
		private var bitmapIdCount :int =0;
		private var bitmapArray:Array;
		private var imageList:Array
		
		public function SplitImage()
		{
			super();
			init()
		}
		
		private function init():void{
			Log.getLogger(Configuration.PICSAEN_LOG).info(" .................Pano Spliting Started .............. \n");
			imageList = PublishModel.getInstance().panoImageList;
			splitImage();
		}
		
		private function splitImage():void{
			var filePath:String = imageList[idCount] as String;
			jpgdata = new ByteArray();
			var stream:FileStream = new FileStream();
			file = new File(filePath)
			stream.open(file, FileMode.READ);
			stream.readBytes( jpgdata);
			stream.close();
			jpg = new Image();
			this.addChild(jpg);
			this.jpg.visible = false;
			jpg.addEventListener( Event.COMPLETE, slice);
			jpg.source = jpgdata;
		}
		
		private function slice( e:Event):void
		{ 
			timer.addEventListener(TimerEvent.TIMER , activateTimer);
			var mainImage:BitmapData = new BitmapData(jpg.contentWidth , jpg.contentHeight );
			
			if (mainImage.height > mainImage.width){
				getImageDataHeight(mainImage)
			}
			else{
				
				getImageDataWidth(mainImage);
			}
			
			getNextSlice();
			
		}
		
		private function getImageDataHeight(bt:BitmapData):void{
			var tileX:Number = bt.width;//Number(jpg.contentHeight); main
			var tileY:Number = Configuration.PANO_IMAGE_SPLIT_SIZE;
			var tilesH:uint = Math.ceil(bt.width / tileX); 
			var tilesV:uint = Math.ceil(bt.height / tileY);
			bt.draw(jpg);
			bitmapArray = new Array();
			
			var tempRect:Rectangle;
			var tempData:BitmapData;
			
			for (var i:Number = 0; i < tilesV; i++)
			{
				if( ( bt.height - (tileY  * i)) >= Configuration.PANO_IMAGE_SPLIT_SIZE){
					tempData = new BitmapData(tileX,tileY);
					tempRect = new Rectangle((tileX * 0),(tileY * i),tileX,tileY);
				}else{
					var dataremaining :Number = bt.height -( tileY * i);
					tempData = new BitmapData(tileX,dataremaining);
					tempRect = new Rectangle((tileX * 0),(tileY * i),tileX,dataremaining);
				}
				
				tempData.copyPixels(bt,tempRect,new Point(0,0));
				bitmapArray.push(tempData);
			}
		}
		
		private function getImageDataWidth(bt:BitmapData):void{
			var tileX:Number =Configuration.PANO_IMAGE_SPLIT_SIZE;
			var tileY:Number = bt.height;
			var tilesH:uint = Math.ceil(bt.width / tileX); 
			var tilesV:uint = Math.ceil(bt.height / tileY);
			bt.draw(jpg);
			bitmapArray = new Array();
			
			var tempRect:Rectangle;
			var tempData:BitmapData;
			
			for (var i:Number = 0; i < tilesH; i++)
			{
				if( ( bt.width - (tileX  * i)) >= Configuration.PANO_IMAGE_SPLIT_SIZE){
					tempData =new BitmapData(tileX,tileY);
					tempRect = new Rectangle((tileX * i),(tileY * 0),tileX,tileY);
				}else{
					var dataremaining :Number = bt.width -( tileX * i);
					tempData = new BitmapData(dataremaining,tileY);
					tempRect = new Rectangle((tileX * i),(tileY * 0),dataremaining,tileY);
				}
				
				tempData.copyPixels(bt,tempRect,new Point(0,0));
				bitmapArray.push(tempData);
			}
		}
		
		private function getNextSlice():void{
			var jpgenc:JPEGEncoder = new JPEGEncoder(72); 
			var imgByteArray:ByteArray = jpgenc.encode( bitmapArray[bitmapIdCount]);                
			var stream:FileStream = new FileStream();
			/*var fileNameRegExp:RegExp = /\bp04(er|ing|ed|s)?\b/*/
			var f:String = file.url
			var outputFileName:String = f.replace(file.name,file.name.split(".")[0]+"_"+bitmapIdCount+".jpg");//fileNameRegExp.exec(file.name).name +"_crop.jpg";
			var newfile:File = new File(outputFileName);
			stream.open(newfile, FileMode.WRITE);
			stream.writeBytes(imgByteArray);
			imgByteArray.clear();
			stream.close();
			timer.start();
		}
		private function activateTimer(event:TimerEvent):void{
			timer.stop();
			if (bitmapIdCount < bitmapArray.length -1){
				bitmapIdCount++;
				getNextSlice()
			}else{
				if(idCount < imageList.length -1){
				idCount++;
				bitmapIdCount =0;
				splitImage()}else{
					///disptach event
				
					Log.getLogger(Configuration.PICSAEN_LOG).info(" .................Pano Spliting Done .............. \n");
					//var jsonSearch:DirectorySearchJson = new DirectorySearchJson()
					EventTransporter.getInstance().dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_SCALE_COMPLETED,this));
				}
			}
		}
	}
}