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
	
	public class AnimatedButtonFeature extends BaseFeature
	{
		private var _json:Object;
		private static const YES:String = 'YES';

		
		public function AnimatedButtonFeature(grp:Group)
		{
			super(grp);
		}
		public override function initFeature():void{
			this.type = Configuration.TYPE_ANIMBTN;
			super.getBaseSubFeatures();
			
			_json = new Object();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			
			_json.id = this.name;
			
			//
			var trigger:PageItem=group.pageItems.itemByName("trigger");
			var content:PageItem=group.pageItems.itemByName("contents");
			//
			var propertyString:String = trigger.extractLabel(Configuration.LABEL);
			if(propertyString.indexOf(type) >=0)	{
				var lables:Object={'before':'NA'};
				lables = JSON.decode(propertyString);
			}	
			/**
			 * Property string fetching from
			 * Textframe
			 * */
			var propObj:Object;
			
			if(this.hasProperties)	{
				propObj = JSON.decode(this.propertyString);
				lables = propObj
			}
			//
			if(lables.before == "draw"){
				_json.animationDuration = lables.duration;
				_json.from = lables.from;
				_json.animationtype = lables.animationType;
				_json.subtype = lables.before;
				_json.closetrigger = lables.closetrigger;
				createDirectory()
				triggerImage();
				contentImage();
				location();
			}else if(lables.before == "slideshow"){
				_json.animationDuration = lables.duration;
				_json.from = lables.from;
				_json.animationtype = lables.animationType;
				_json.subtype = lables.before;
				createDirectory();
				triggerImage();
				closeTriggerLocation();
				closeTriggerImage();
				generateSlideImage();
				locationSlideShow();
			}else if(lables.before == "scale"){
				_json.animationDuration = lables.duration;
				_json.from = lables.from;
				_json.animationtype = lables.animationType;
				_json.subtype = lables.before;
				createDirectory()
				triggerImage();
				contentImage();
				location();
			}
			/**
			 * Property string fetching from
			 * Textframe
			 * */
			if(this.hasProperties)	{
				propObj = JSON.decode(this.propertyString);
				for(var key:String in propObj)	{
					_json[key] = propObj[key];
				}
			}
			
			_json.subfeatures = super.getJSON();
		}
		public override function createDirectory():void{
			var pageDir : File = new File(this.directory+this.name);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		private function triggerImage():void{
			var trigger:Group =group.groups.itemByName("trigger") as Group;
			var exportf:File=new File(directory+this.name+File.separator+trigger.name+this.exetension);
			trigger.exportFile(ExportFormat.PNG_FORMAT, exportf);
			_json.buttonimage =this.serverURI +this.name+File.separator+ trigger.name + this.exetension
		}
		private function closeTriggerImage():void{
			var closetrigger:Group =group.groups.itemByName("closetrigger") as Group;
			var exportf:File=new File(directory+this.name+File.separator+closetrigger.name+this.exetension);
			closetrigger.exportFile(ExportFormat.PNG_FORMAT, exportf);
			_json.closeTrigger =this.serverURI +this.name+File.separator+ closetrigger.name + this.exetension
		}
		private function contentImage():void{
			var trigger:Group =group.groups.itemByName("contents") as Group;
			var exportf:File=new File(directory+this.name+File.separator+trigger.name+this.exetension);
			trigger.exportFile(ExportFormat.PNG_FORMAT, exportf);
			_json.image =this.serverURI +this.name+File.separator+ trigger.name + this.exetension
		}
		private function location():void{
			var tbounds:BoundVO;
			var cbounds:BoundVO
			var trigger:PageItem=group.pageItems.itemByName("trigger");
			var content:PageItem = group.pageItems.itemByName('contents');
			
			if(!(group.parent is Group)){
	
				tbounds = new BoundVO(trigger as PageItem);
				cbounds = new BoundVO(content as PageItem);
			}
			else	{
			
				tbounds = new BoundVO(trigger as PageItem,group.parent as PageItem);
				cbounds = new BoundVO(content as PageItem,group.parent as PageItem);
			}
		
			var pointTrigger:Object = tbounds.createBound();
			var pointContent:Object = cbounds.createBound();
			
			_json.trigger = pointTrigger.t;
			_json.location = pointContent.l;
		}
		private function locationSlideShow():void{
			var tbounds:BoundVO;
			var cbounds:BoundVO;
			var ctbounds:BoundVO;
			var trigger:PageItem=group.pageItems.itemByName("trigger");
			var location:PageItem = group.pageItems.itemByName("location");
			var closeTrigger:PageItem = group.pageItems.itemByName("closetrigger");
			//
			if(!(group.parent is Group)){
				tbounds = new BoundVO(trigger as PageItem);
				cbounds = new BoundVO(location as PageItem);
				ctbounds = new BoundVO(closeTrigger as PageItem);
			}
			else	{
				tbounds = new BoundVO(trigger as PageItem,group.parent as PageItem);
				cbounds = new BoundVO(location as PageItem,group.parent as PageItem);
				ctbounds = new BoundVO(closeTrigger as PageItem,group.parent as PageItem);
			}
			var pointTrigger:Object = tbounds.createBound();
			var pointLocation:Object = cbounds.createBound();
			var pointCloseTrigger:Object = ctbounds.createBound();
			_json.trigger = pointTrigger.t;
			_json.location = pointLocation.l;
			_json.closeTriggerLocation = pointCloseTrigger.t;
		}
		//
		private function closeTriggerLocation():void{
			var tbounds:BoundVO;
			var closetrigger:PageItem=group.pageItems.itemByName("closetrigger");
			
			if(!(group.parent is Group)){
				
				tbounds = new BoundVO(closetrigger as PageItem);
			}
			else	{
				
				tbounds = new BoundVO(closetrigger as PageItem,group.parent as PageItem);
			}
			
			var closePointTrigger:Object = tbounds.createBound();
			_json.closeTriggerLocation = closePointTrigger.l;
		}
		private function generateSlideImage():void{
			var images:Array;
			if (images==null || images.length==0){
				images = new Array();
				var slideitems:PageItems = (group.groups.itemByName("slides") as Group).pageItems;
				group.groups.itemByName("slides").visible=true;
				for (var i:int=0; i<slideitems.length; i++){
					for (var j:int=0; j<slideitems.length; j++){
						slideitems.item(j).visible=false;
					}
					var item:PageItem = slideitems.item(i) as PageItem;
					item.visible=true;
					var exportFile:File=new File(directory+this.name+File.separator+item.name+this.exetension);
					item.parent.exportFile(ExportFormat.PNG_FORMAT, exportFile);
					images.push(this.serverURI +this.name+File.separator+ item.name + this.exetension);
				}
			}
			_json.images =images;
		}
		public function badHide(isHide:Boolean,ftye:String):void	{
			this.group.visible = isHide;
		}
		
		public override function getJSON():Object	{
			return _json;
		}		
	}
}