package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	
	public class TriggerablePanoramaFeature extends BaseFeature
	{
		private var _json : Object;
		
		private static var TRIGGER : String = "_trigger";
		private static var TRIGGERABLE_PANORAMA : String = "triggerablepanaroma";
		
		public function TriggerablePanoramaFeature(grp:Group)
		{
			super(grp);
		}
		
		public override function initFeature():void	{
			var view : PageItem, contents  : PageItem, trigger : PageItem, openTrigger : PageItem;
			var vbounds:BoundVO, pgbound:BoundVO, tbound : BoundVO, topenBound : BoundVO;
			var boundObj:Object, tboundObj : Object, topenObj : Object;
			var imageName : String, trImageName : String;
			var exportImage : File, trFile : File;
			
			this.type = Configuration.TYPE_TRIGGERABLEPANO;
			this.getBaseSubFeatures();
			
			_json = new Object();
			_json.type = TRIGGERABLE_PANORAMA;
			_json.orientation = BoundVO.getOrientationType(this.orientation);
			
			
			
			
			view = group.pageItems.itemByName("view");
			contents = group.pageItems.itemByName("contents");
			trigger = group.pageItems.itemByName("trigger-close");
			openTrigger = group.pageItems.itemByName("trigger-open");
			
			if(!(group.parent is Group))
				vbounds = new BoundVO(view as PageItem);
			else
				vbounds = new BoundVO(view as PageItem,group.parent as PageItem);
			
			pgbound = new BoundVO(group as PageItem);
			tbound = new BoundVO(trigger);
			topenBound = new BoundVO(openTrigger);
			
			boundObj = vbounds.createBound();
			tboundObj = tbound.createBound();
			topenObj = topenBound.createBound();
			
			imageName =  this.directory + this.name + this.exetension_JPG;
			trImageName = this.directory + this.name + TRIGGER + this.exetension;
			
			_json.location = boundObj.l;
			_json.trigger = topenObj.t;
			_json.closeTriggerLocation = tboundObj.l;
			_json.contentsize ="{"+pgbound.width+","+pgbound.height+"}";
			_json.image   = this.serverURI + this.name + this.exetension_JPG;
			_json.closeTrigger = this.serverURI + this.name +  TRIGGER + this.exetension;
			_json.subfeatures = super.getJSON();
			_json.scrolledValue = "{0,0}";
			_json.orientation  =  BoundVO.getOrientationType(this.orientation);
			
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
			
			super.createDirectory();
			
			//badHideInnerFeatures(false);
			
			exportImage = new File(imageName);
			trFile = new File(trImageName);
			
			
			contents.exportFile(ExportFormat.jpg, exportImage);
			trigger.exportFile(ExportFormat.pngFormat, trFile);
			//badHideInnerFeatures(true);
		}
		
		
		public function badHide(isHide:Boolean,ftye:String):void	{
			var contents : Group  = group.groups.itemByName("contents");
			var trigger : Group = group.groups.itemByName("trigger-close");
			//var contents  : Group = group.groups.itemByName("contents");
			trigger.visible = isHide;
			contents.visible = isHide;
			//contents.visible = isHide;
			
		}
		
		public override function getJSON():Object	{
			return this._json;
		}
		
		/**
		 * Publishing inner features
		 * */
		public override function getBaseSubFeatures():void	{
			super.getBaseSubFeatures();
			
			var iterator : IIterator = this.subFeatureList.keyIterator();
			var feature : IFeature;
			var key : String;
			while(iterator.hasNext())	{
				key = iterator.next();
				feature = this.subFeatureList.itemFor(key);
				feature.directory = this.directory +  this.name + File.separator ;
				feature.orientation = this.orientation;
				feature.name = key;
				trace("\n\n\n");
				feature.initFeature();
				trace(feature.toString());
				trace("\n\n\n");
			}
			
		}
		/**
		 * there wont be any subfeatures inside the triggerable panaorma
		 * If found in future uncomment the below method
		 * */
		/*private function badHideInnerFeatures(isHide:Boolean):void	{
			var iterator : IIterator = this.subFeatureList.keyIterator();
			var feature : IFeature;
			while(iterator.hasNext())	{
				feature = this.subFeatureList.itemFor(iterator.next()) as IFeature;
				switch(feature.featureType)	{
					case Configuration.TYPE_DRAW : DrawFeature(feature).badHide(isHide,Configuration.TYPE_DRAW); break;
					case Configuration.TYPE_SLIDESHOW : SlideShowFeature(feature).badHide(isHide,Configuration.TYPE_SLIDESHOW); break;
					case Configuration.TYPE_SCROLL : ScrollFeature(feature).badHide(isHide,Configuration.TYPE_SCROLL); break;
				}
			}
		}*/
	}
}