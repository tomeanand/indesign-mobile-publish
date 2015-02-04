package com.picsean.publish.model
{
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;
	import flash.geom.Point;

	public class LayoutVO
	{
		public var orientation : String;
		public var width : Number; // from feature manager
		public var height : Number; // from feature manager
		public var ratio : Number // from feature manager
		public var pageDimension : Point; // width and height of page
		public var publishDirectory : String;
		public var device : String;
		
		public function LayoutVO(orient:String, w:Number, h:Number, r:Number, pgDimension:Point, pubPath : String, device : String)
		{
			this.orientation = orient;
			this.width = w;
			this.height = h;
			this.ratio = r;
			this.pageDimension = pgDimension;
			this.device = device;
			publishDirectory = createPubPath(pubPath);
			trace(":::::::::"+publishDirectory)
		}
		
		public function toString():String	{
			return "{height:"+height+"} {width:"+width+"} {ratio:"+ratio+"} {orient:"+orientation+"}  {PageDimension:"+pageDimension.toString()+"}";
		}
		
		public function isPanoPage():Boolean	{
			if(this.device == Configuration.DEVICE_IPAD || this.device == Configuration.DEVICE_IPAD_RETINA)	{
			//PSEUDO : (pageHeight / ratio) >= (height +1) || (pageWidth/ratio) >= (width + 1)
				var ratioY : Number = Number( pageDimension.y / ratio );
				var ratioX : Number = Number( pageDimension.x / ratio );
				var newHeight : Number = height + 1;
				var newWidth : Number = width + 1;
				trace("(("+ratioY+") >= ("+newHeight+")) || (("+ratioX+") >= ("+newWidth+"))");
				if( (ratioY >= newHeight) || (ratioX >= newWidth) ){
					return true;
				}
			}
			return false;
		}
		private function createPubPath(p:String):String	{
			var pathSplit : Array = p.split(File.separator)
			return pathSplit[pathSplit.length - 3] + File.separator +
				pathSplit[pathSplit.length - 2] + File.separator + 
				pathSplit[pathSplit.length - 1];
		}
	}
}