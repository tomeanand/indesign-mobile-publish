package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.adobe.indesign.PageItems;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	import flash.filesystem.File;
	
	public class ScrollFeature extends BaseFeature
	{
		private var _json:Object;
		
		public function ScrollFeature(grp:Group)
		{
			super(grp);
		}
		
		public override function initFeature():void{
			this.type = Configuration.TYPE_SCROLL;
			super.getBaseSubFeatures();
			
			_json = new Object();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			
			var trigger1:PageItem=group.pageItems.itemByName("trigger1");
			var content:PageItem=group.pageItems.itemByName("slides");
			var trigger2:PageItem = group.pageItems.itemByName("trigger2");
			
			var trg1:BoundVO;
			var trg2:BoundVO;
			var slide:BoundVO
			
			if(!(group.parent is Group)){
				trg1 = new BoundVO(trigger1 as PageItem);
				trg2 = new BoundVO(trigger2 as PageItem);
				slide = new BoundVO(content as PageItem);
			}
			else	{
				trg1 = new BoundVO(trigger1 as PageItem,group.parent as PageItem);
				trg2 = new BoundVO(trigger2 as PageItem,group.parent as PageItem);
				slide = new BoundVO(content as PageItem,group.parent as PageItem);
			}
			var pointContent:Object = slide.createBound();
			var pointTrigger1:Object = trg1.createBound();
			var pointTrigger2:Object = trg2.createBound();
			_json.location = pointContent.l;
			_json.trigger1 = pointTrigger1.t;
			_json.trigger2 = pointTrigger2.t;
			
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
			generateSlideImage();
		}
		
		public override function createDirectory():void{
			var pageDir : File = new File(this.directory+this.name);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		
		public function badHide(isHide:Boolean,ftye:String):void	{
			this.group.visible = true;
			var content:Group = group.groups.itemByName("slides") as Group;
			content.visible = isHide;
		}
		
		private function generateSlideImage():void{
			var images:Array;
			if (images==null || images.length==0){
				images = new Array();
				var scrollitm:PageItems = (group.groups.itemByName("slides") as Group).pageItems;
				for (var i:int=0; i<scrollitm.length; i++){
					var item:PageItem = scrollitm.item(i) as PageItem;
					scrollitm.everyItem().visible=false;
					item.visible=true;
					var exportFile:File=new File(directory+this.name+File.separator+item.name+this.exetension);
					(group.groups.itemByName("slides") as Group).exportFile(ExportFormat.pngFormat, exportFile);
					images.push(this.serverURI +this.name+File.separator+ item.name + this.exetension);
				}
			}
			_json.images = images;
		}
		public override function getJSON():Object	{
			_json.subfeatures = super.getJSON();
			return _json;
		}
	}
}