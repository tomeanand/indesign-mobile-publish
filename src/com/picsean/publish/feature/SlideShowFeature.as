package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.adobe.indesign.PageItems;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	import flash.filesystem.File;
	
	import mx.effects.easing.Exponential;
	
	public class SlideShowFeature extends BaseFeature
	{
		private var _json:Object;
		private static const YES:String = 'YES'
			private static const NO:String = "YES"
		
		public function SlideShowFeature(grp:Group)
		{
			super(grp);
		}
		public override function initFeature():void{
			this.type = Configuration.TYPE_SLIDESHOW;
			super.getBaseSubFeatures();
			
			_json = new Object();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			
			var trigger:PageItem=group.pageItems.itemByName("trigger");
			var content:PageItem=group.pageItems.itemByName("slides");
			var triggerclose:PageItem = group.pageItems.itemByName("closetrigger");
			
			if(	this.skipFeature(trigger,content,triggerclose) )	{
				this.isCorrupted = true;
				return;
			}
			
			var tbounds:BoundVO;
			var cbounds:BoundVO;
			var trgclosebounds:BoundVO
			
			if(!(group.parent is Group)){
				cbounds = new BoundVO(group.pageItems.itemByName('location') as PageItem);
				tbounds = new BoundVO(trigger as PageItem);
				trgclosebounds = new BoundVO(triggerclose as PageItem);
			}
			else	{
				cbounds = new BoundVO(group.pageItems.itemByName('location') as PageItem,group.parent as PageItem);
				tbounds = new BoundVO(trigger as PageItem,group.parent as PageItem);
				trgclosebounds = new BoundVO(triggerclose as PageItem,group.parent as PageItem);
			}
			//
			var pointContent:Object = this.fixLocation(cbounds, new BoundVO(this.group as PageItem));
			var pointTrigger:Object = this.fixLocation(tbounds, new BoundVO(this.group as PageItem));
			var pointTriggerClose:Object = this.fixLocation(trgclosebounds, new BoundVO(this.group as PageItem));
			//		
			_json.trigger = pointTrigger.t;
			_json.location = pointContent.l;
			//_json.triggerable  = YES;
			_json.closetrigger = YES;
			_json.triggerable = YES;
			//lables.triggerable = YES
			_json.closeTriggerLocation = pointTriggerClose.t;
			createDirectory();
			
			///for close trigger 
			closeTriggerImage();
			
			////////////////////////
				
			generateSlideImage();
			
			//////
			//
			var propertyString:String = group.extractLabel(Configuration.LABEL);
			if(propertyString.indexOf(Configuration.TYPE_SLIDESHOW_TRIGGER) >=0)	{
				var lables:Object={'before':'NA'};
				lables = JSON.decode(propertyString);
				lables.triggerable  ==  true?(_json.triggerable  = YES) :( _json.triggerable  = NO);
			}	else{
				_json.triggerable  = YES;
			}
			//
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
		
		public override function createDirectory():void{
			var pageDir : File = new File(this.directory+this.name);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		
		public function badHide(isHide:Boolean,ftye:String):void	{
			if(this.isCorrupted)	{ 
				isHide ? logger.error("Skipped feature "+this.type+" named "+this.name) : "";
				return;	
			}
			
			this.group.visible = true;
			var content:Group = group.groups.itemByName("slides") as Group;
			var location:Group = group.groups.itemByName('location') as Group
			var triggerlocation:Group =group.groups.itemByName('closetrigger') as Group
			content.visible = isHide;
			location.visible = isHide;
			triggerlocation.visible =isHide;
			}
		
		private function generateSlideImage():void{
			var images:Array;
			if (images==null || images.length==0){
				images = new Array();
				var slidegp : Group = group.groups.itemByName("slides") as Group
				//var slideitems:PageItems = slidegp.pageItems;
				var slideitems:PageItems = slidegp.pageItems;
				var slideItem : Group;
				for(var i:Number = 0; i<slidegp.groups.length; i++)	{
					slideItem = slidegp.groups.item(i);
					var exportFile:File=new File(directory+this.name+File.separator+slideItem.name+this.exetension);
					slideItem.exportFile(ExportFormat.PNG_FORMAT, exportFile);
					images.push(this.serverURI +this.name+File.separator+ slideItem.name + this.exetension);
				}
//				group.groups.itemByName("slides").visible=true;
//				for (var i:int=0; i<slideitems.length; i++){
//					for (var j:int=0; j<slideitems.length; j++){
//						slideitems.item(j).visible=false;
//						trace(slidegp.groups.item(i) is Group)
//					}
//					try	{
//						var slideGroup:Group = slideitems.item(i) as Group
//						if(slideGroup)	{
//							trace("Its a group")
//						}
//					}
//					catch(error:Error)	{
//						trace(error.message)
//					}
//					var item:PageItem = slideitems.item(i) as PageItem;
//					item.visible=true;
//					var exportFile:File=new File(directory+this.name+File.separator+item.name+this.exetension);
//					item.parent.exportFile(ExportFormat.PNG_FORMAT, exportFile);
//					images.push(this.serverURI +this.name+File.separator+ item.name + this.exetension);
//				}
			}
			_json.images =images;
		}
		
		private function closeTriggerImage():void{
			var closetrigger:Group =group.groups.itemByName("closetrigger") as Group;
			var exportf:File=new File(directory+this.name+File.separator+closetrigger.name+this.exetension);
			closetrigger.exportFile(ExportFormat.PNG_FORMAT, exportf);
			_json.closeTrigger =this.serverURI +this.name+File.separator+ closetrigger.name + this.exetension
		}
		
		public override function getJSON():Object	{
			_json.subfeatures = super.getJSON();
			return _json;
		}
	}
}