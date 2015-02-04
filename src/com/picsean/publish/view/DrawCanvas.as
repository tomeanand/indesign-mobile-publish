package com.picsean.publish.view
{
	import com.picsean.publish.automation.ImageScale;
	import com.picsean.publish.automation.ImageScaleOperation;
	import com.picsean.publish.automation.SplitImage;
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.core.UIComponent;
	
	public class DrawCanvas extends Canvas
	{
		//private var imgScale:ImageScale
		private var scaleOperation:ImageScaleOperation;
	
		public function DrawCanvas()	{
			super();
			Init();
		}
		
		private function Init():void{
			//imgScale = new ImageScale()
			//this.addChild(imgScale);
			
			EventTransporter.getInstance().addEventListener(EventFilePublish.EVENT_SCALE_IMAGES, onScaleCompleted);
			EventTransporter.getInstance().addEventListener(EventFilePublish.EVENT_PANO_SLICE, onImageSlice);
			
		}
		
		private function onScaleCompleted(event:EventFilePublish):void{
			scaleOperation = new ImageScaleOperation();
			scaleOperation.initOperation(event.data.resultData as ArrayCollection);
				
		//imgScale.move(100,100);
		//imgScale.scaleImages(event.data.resultData as ArrayCollection);
		}
		
		private function onImageSlice(event:EventFilePublish):void{
			var splitImg :SplitImage = new SplitImage();
		}
		
	}
}