package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;
	
	public class CommonDrawFeature extends DrawFeature
	{
		private var _json :Object;
		private var caller:String;
		
		public var flipBound:BoundVO;
		
		public function CommonDrawFeature(grp:Group,caller:String=Configuration.TYPE_PANORAMA_EVENT)
		{
			super(grp);
			this.caller = caller;
		}
		
		
		
		public override function initFeature():void	{
			
			// checking the type to draw or drawclose;
			/*if(this.name.split("-")[0] == Configuration.TYPE_DRAWCLOSE)	{ this.type = Configuration.TYPE_DRAWCLOSE;	}
			else	{this.type = Configuration.TYPE_DRAW;	}*/
			/**
			 *For Draw and Drawclose the type would be always DRAW; 
			 * */
			this.type = Configuration.TYPE_DRAW;
		
			
			
			_json = new Object();
			_json.type = this.type;
			
			var content:PageItem = group as PageItem;
			
			var cbounds:BoundVO;
			
			if(!(group.parent is Group)){
				cbounds = new BoundVO(group as PageItem);
			}
			else	{
				cbounds = new BoundVO(group as PageItem,group.parent as PageItem);
			}
			
			
			if(caller == Configuration.TYPE_FLIP_BOOK)	{
				cbounds.xpos += flipBound.xpos;
				cbounds.ypos += flipBound.ypos;
			}
			var pointContent:Object = cbounds.createBound();
			
			//var pointContent:Object = this.fixLocation(cbounds, new BoundVO(this.group as PageItem))
			//var pointTrigger:Object = this.fixLocation(tbounds, new BoundVO(this.group as PageItem));
			
			_json.location = pointContent.l;
			
			
			var exportImage : File;
			var imageName : String = this.directory + this.name + this.exetension;
			
			super.createDirectory();
	
			exportImage = new File(imageName);
			content.exportFile(ExportFormat.pngFormat, exportImage);

			_json.image  = this.serverURI + this.name + this.exetension;
			
		}
		public override function getJSON():Object	{
			return _json;
		}
	}
}