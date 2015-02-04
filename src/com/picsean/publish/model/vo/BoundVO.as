package com.picsean.publish.model.vo
{
	import com.adobe.indesign.PageItem;
	import com.picsean.publish.model.PublishModel;

	public class BoundVO
	{
		public var xpos:int;
		public var ypos:int;
		public var height:int;
		public var width:int
		
		private var item:PageItem;
		private var parent:PageItem;
		
		private  static var _model:PublishModel = PublishModel.getInstance();
		
		public function BoundVO(itm:PageItem,parent:PageItem=null)
		{
			this.item = itm;
			this.parent = parent;
			getBounds();
		}
		
		private function getBounds():void{
			var bounds:Array = this.item.visibleBounds as Array;
			if(this.parent == null)	{
				this.xpos = bounds[1] / _model.pageRatio;
				this.ypos = bounds[0] / _model.pageRatio;
				this.width = (bounds[3]-bounds[1]) / _model.pageRatio;
				this.height = (bounds[2]-bounds[0]) / _model.pageRatio;
			}
			else	{
				var parentBounds:Array = this.parent.visibleBounds as Array;
				this.xpos = ( bounds[1] -parentBounds[1] ) / _model.pageRatio;
				this.ypos = ( bounds[0] -parentBounds[0] ) / _model.pageRatio;
				this.width = Math.round(( bounds[3] -bounds[1] ) / _model.pageRatio);
				this.height = Math.round(( bounds[2] -bounds[0] ) / _model.pageRatio);
			}
		}
		
		public function createBound():Object	{
			var location:String = "{{" + this.xpos + "," + this.ypos + "},{" + this.width + "," + this.height + "}}";
			var trigger:String = "{{" + this.xpos + "," + this.ypos + "},{" + this.width + "," + this.height + "}}";
			return {l:location,t:trigger}
		}
		
		public function createInnerBound(bound:BoundVO):Object	{
			var location:String = "{{" + Number(this.xpos + bound.xpos) + "," + Number(this.ypos + bound.ypos) + "},{" + this.width + "," + this.height + "}}";
			var trigger:String = "{{" + Number(this.xpos + bound.xpos) + "," + Number(this.ypos + bound.ypos) + "},{" + this.width + "," + this.height + "}}";
			return {l:location,t:trigger}
		}
		
		public static function getOrientationType(type:String):String{
			if(type =='l') return 'landscape'
			else if (type == 'p') return 'portrait';
			return null
		}
		
	}
}