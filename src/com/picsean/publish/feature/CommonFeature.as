package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.LayoutVO;
	import com.picsean.publish.model.vo.BoundVO;
	
	public class CommonFeature extends BaseFeature
	{
		public var id:String;
		
		private var _json:String;
		private var bound : BoundVO;
		
		
		public function CommonFeature(type:String,id:String,json:String, boundVO:BoundVO, layout:LayoutVO)
		{
			super(null);
			this.type = type;
			this.id = id;
			this._json = json;
			this.bound = boundVO;
			this.layout = layout;
			
		}
		
		public override function initFeature():void	{
			//do nothing
		}
		
		public override function getJSON():Object	{
			return JSON.decode(_json) ;
		}
		
		public function shiftPosition(mainPos : Array, lvo:LayoutVO):void	{
			if(this.bound == null) {return}
			if(this.type == "text" || this.type.indexOf("timer") != -1)	{return}
			var xpos : Number = int(mainPos[1] / lvo.ratio);
			var ypos  : Number = int(mainPos[0] / lvo.ratio);
			/**
			 * Highly risk involved split
			 * Blame this, if anything fails for main features position
			 * 
			 * better solution is pass the boundVO to the class
			 * change the trigger and location instead of spliting it
			 * 
			 * */
			var rectJson : Object = getJSON();
			/*var loc : Array = String(rectJson.location).split("},{");
			var locPos : Array = String(loc[0]).substring(2).split(",");
			var sizePos : Array = String(loc[1]).substring(0, String(loc[1]).length-2 ).split(",");
			
			var newXpos : Number = Number( locPos[0] ) + xpos;
			var newYpos : Number = Number( locPos[1] ) + ypos;
			var newWidth :String = sizePos[0];
			var newHeight :String = sizePos[1];*/
			
			/**
			 * Can make use of the below function ( fixLocation() ) more effectively
			 * */
			//this.fixLocation()
			
			var location:String = "{{" + Number(this.bound.xpos+xpos) + "," + Number(this.bound.ypos+ypos) + "},{" + bound.width + "," + bound.height + "}}";
			var trigger:String = "{{" + Number(this.bound.xpos+xpos) + "," + Number(this.bound.ypos+ypos) + "},{" + bound.width + "," + bound.height + "}}";
			
			rectJson.location = location;			
			rectJson.trigger = trigger;		
			
			this._json = JSON.encode(rectJson);
			//trace("______________"+ypos+"__________________"+xpos+"__________________"+locPos+"__________________"+sizePos+"_____")
			
		}
	}
}