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

	public class ScaleFeature extends BaseFeature
	{
		
		private var _json:Object;
		private var _group:Group
		private static const BOUNCEVALUE:String = 'bounceValue';
		private static const ANIMATIONDURATION:String ='animationDuration';
		private static const BOUNCEDURATION:String ='bounceDuration';
		private static const TRIGGERVISIBLE :String = 'isTriggerVisible';
		private static const TYPE :String = 'type';
		 

		public function ScaleFeature(grp:Group)
		{
			super(grp)
			this._group = grp;
		}
		
		public override function initFeature():void{
			this.type = Configuration.TYPE_SCALE;
			super.getBaseSubFeatures();
			_json = new Object();
			_json = getLabels();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			
			var trigger:PageItem = group.pageItems.itemByName("trigger") as PageItem;
			var content:PageItem = group.pageItems.itemByName("contents") as PageItem;
			
			var tbounds:BoundVO;
			var cbounds:BoundVO;
			
			if(!(group.parent is Group)){
				cbounds = new BoundVO(content as PageItem);
				tbounds = new BoundVO(trigger as PageItem);
			}
			else	{
				cbounds = new BoundVO(content as PageItem,group.parent as PageItem);
				tbounds = new BoundVO(trigger as PageItem,group.parent as PageItem);
			}
			var pointContent:Object = this.fixLocation(cbounds, new BoundVO(this.group as PageItem));
			var pointTrigger:Object = this.fixLocation(tbounds, new BoundVO(this.group as PageItem));
			
			_json.trigger = pointTrigger.t;
			_json.location = pointContent.l;
			
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
			
			
			createDirectory();
			generateImages();
			
		}
		
		public override function createDirectory():void{
			var pageDir : File = new File(this.directory+this.name);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		private function getLabels():Object{
			var propstr:String = PageItem(_group).extractLabel(Configuration.LABEL);
			if(propstr.indexOf(Configuration.TYPE_SCALE)<0){
			var obj:Object = new Object();
			obj[TYPE] = Configuration.TYPE_SCALE;
			obj[BOUNCEDURATION] = 0.1;
			obj[BOUNCEVALUE] = 0.1;
			obj[ANIMATIONDURATION] =1;
			obj[TRIGGERVISIBLE] = 'YES';
			
			return obj;
			}
			var data:Object = JSON.decode(propstr);
			return data;
		}
		
		public function badHide(isHide:Boolean,ftye:String):void	{
			this.group.visible = true;
			var content:Group = group.groups.itemByName("contents") as Group;
			var trigger:Group = group.groups.itemByName("trigger") as Group;
			content.visible = isHide;
			if(_json.isTriggerVisible == 'NO')trigger.visible = isHide;
		}
		
		private function generateImages():void{
			var content:Group =group.groups.itemByName("contents") as Group;
			var exportf:File=new File(directory+this.name+File.separator+content.name+this.exetension);
			content.exportFile(ExportFormat.PNG_FORMAT, exportf);
			_json.image =this.serverURI +this.name+File.separator+ content.name + this.exetension
			
			
		}
		public override function getJSON():Object	{
			_json.subfeatures = super.getJSON();
			return _json;
		}
	}
}