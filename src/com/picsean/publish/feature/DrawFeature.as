package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	import flash.filesystem.File;
	
	public class DrawFeature extends BaseFeature
	{
		private var _json:Object;
		private var _currentVisibleState:Boolean = false;
		private var explicitType:String;
		private var _group:Group
		
		public function DrawFeature(grp:Group)
		{
			super(grp);
			this._group = grp;
			
		}
		
		public override function initFeature():void	{
			
			// checking the type to draw or drawclose;
			/*if(this.name.split("-")[0] == Configuration.TYPE_DRAWCLOSE)	{ this.type = Configuration.TYPE_DRAWCLOSE;	}
			else	{this.type = Configuration.TYPE_DRAW;	}*/
			/**
			 *For Draw and Drawclose the type would be always DRAW; 
			 * */
			this.type = Configuration.TYPE_DRAW;
			explicitType = this.name.split("-")[0];
			
			if(this.explicitType != Configuration.TYPE_MASK){
				super.getBaseSubFeatures();
				//logger.info('{0} are the base Subfeatures found in {1}',this.baseSubFeatures.keysToArray().toString(),this)
			}
			
			_json = new Object();
			if(getLabels()){
				_json.type = Configuration.TYPE_MULTIPLEDRAW;
			}else{
			_json.type = this.type;}
			if(this.explicitType != Configuration.TYPE_MASK)
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			
			//checking feature group formation
			var trigger:PageItem = getPageItem("trigger");
			var content:PageItem = getPageItem("contents");
			
			if(	this.skipFeature(trigger,content) )	{
				this.isCorrupted = true;
				return;
			}
			
			
			
			var triggerGroup:Group;
			
			var tbounds:BoundVO;
			var cbounds:BoundVO;
			
			if(!(group.parent is Group)){
				cbounds = new BoundVO(group as PageItem);
				tbounds = new BoundVO(trigger as PageItem);
			}
			else	{
				cbounds = new BoundVO(group as PageItem,(group.parent) as PageItem);
				tbounds = new BoundVO(trigger as PageItem,(group.parent) as PageItem);
			}
			var pointContent:Object = this.fixLocation(cbounds, new BoundVO(this.group as PageItem))
			var pointTrigger:Object = this.fixLocation(tbounds, new BoundVO(this.group as PageItem));
			
			
			
			_json.trigger = pointTrigger.t;
			_json.location = pointContent.l;
			
			
			_json.closetrigger = (this.explicitType == Configuration.TYPE_DRAW || this.explicitType == Configuration.TYPE_MASK ? "NO" : "YES");
			
			
			var exportImage : File;
			var imageName : String = this.directory + this.name + this.exetension;
			_currentVisibleState = group.visible;
			super.createDirectory();
			
			if(this.explicitType == Configuration.TYPE_DRAWCLOSE)	{
				exportImage = new File(imageName);
				content.exportFile(ExportFormat.pngFormat, exportImage);
			}
			if(this.explicitType == Configuration.TYPE_DRAW)	{
				
				triggerGroup = group.groups.itemByName("trigger");
				triggerGroup = triggerGroup.groups.itemByName("normal");
				triggerGroup.visible = false;
				exportImage = new File(imageName);
				group.exportFile(ExportFormat.pngFormat, exportImage);
				triggerGroup.visible = true;
			}
			if(this.explicitType == Configuration.TYPE_MASK){
				
				var maskF:File = new File(this.maskPath);
				
				var fileLoc:File=new File(imageName);
				maskF.copyTo(fileLoc,true);
			}
			group.visible = _currentVisibleState;
			_json.image  = this.serverURI + this.name + this.exetension;
			
			/**
			 * Property string fetching from
			 * Textframe
			 * */
			if(this.hasProperties)	{
				var propObj:Object = JSON.decode(this.propertyString);
				for(var key:String in propObj)	{
					_json[key] = propObj[key];
				}
			}
			
		}
		
		public function badHide(isHide:Boolean,ftye:String):void	{
			if(this.isCorrupted)	{ 
				isHide ? logger.error("Skipped feature "+this.type+" named "+this.name) : "";
				return;	
			}
			
			this.group.visible = true;
			var content:Group = group.groups.itemByName("contents") as Group;
			var trigger:Group = group.groups.itemByName("trigger") as Group;
			var triggerGroup:Group;
			if(explicitType == Configuration.TYPE_DRAWCLOSE)	{
				content.visible = isHide;
			}
			else if(explicitType == Configuration.TYPE_DRAW)	{
				triggerGroup = trigger.groups.itemByName("selected");
				content.visible = isHide;
				triggerGroup.visible = isHide;
			}
		}
		/* getLabels  is used to check whether to make the draw feature multipledraw. */
		private function getLabels():Boolean{
			var propstr:String = PageItem(_group).extractLabel(Configuration.LABEL);
			if(propstr.indexOf(Configuration.TYPE_DRAW_MULTI_TIMER)<0){
				return false;
			}
			
			return true;
		}
		
		public override function getJSON():Object	{
			
			if(this.explicitType != Configuration.TYPE_MASK)
			_json.subfeatures = super.getJSON();
			
			return _json;
		}
		
	}
}