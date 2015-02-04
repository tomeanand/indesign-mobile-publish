package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.Groups;
	import com.adobe.indesign.Link;
	import com.adobe.indesign.PageItem;
	import com.adobe.indesign.PageItems;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.core.FeatureFactory;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.model.vo.PageVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	
	public class AccelerometerTrigger extends BaseFeature
	{
		
		private static const DROPS : String = "drop-";
		private static const FEATURE_CONTENT : String = "accelcontent";
		private var _json:Object;
		private var featureContents : LinkedMapFx = new LinkedMapFx();
		private var _name : String;
		
		public function AccelerometerTrigger(grp:Group)
		{
			super(grp);
		}
		
		public override function initFeature():void{
			this.type = Configuration.TYPE_ACCELEROMETERTRIGGER;
			_json = new Object();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			_json.location = triggerLocation(this.group,"drag");
           
			var borderBound : BoundVO = new BoundVO(this.group as PageItem);
			var bound:Object = borderBound.createBound();
			_json.boundary = bound.l;
			
			
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
			
			getAccelFeatures();
			getBaseSubFeatures();
			
			_json.subfeatures = super.getJSON();
			createDirectory();
			generateImages();
		}
		public override function createDirectory():void{
			var pageDir : File = new File(this.directory+this.name);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		private function triggerLocation(g:Group,name:String):String{
			var bounds:Array = group.visibleBounds as Array;
			var xpos:int = bounds[1] / layout.ratio;
			var ypos:int = bounds[0] / layout.ratio;
			var tbounds:BoundVO;
			var drag:PageItem=g.pageItems.itemByName(name);
			tbounds = new BoundVO(drag as PageItem,group as PageItem);
			var trigger:String = "{{" + Number(tbounds.xpos+xpos) + "," + Number(tbounds.ypos+ypos) + "},{" + tbounds.width + "," + tbounds.height + "}}";
			return(trigger);
		}
		private function generateImages():void{
			var drag:Group = group.groups.itemByName("drag") as Group;
			var exportf:File = new File(this.directory+this.name+File.separator+drag.name+this.exetension);
			drag.exportFile(ExportFormat.PNG_FORMAT, exportf);
			_json.image =this.serverURI +this.name+File.separator+ drag.name + this.exetension;
		}
		
		private function getAccelFeatures():void	{
			var contentGrp : Group;
			var featureContent : Group;
			var feature : IFeature;
			for(var i:Number = 0; i<this.group.groups.count(); i++)	{
				contentGrp = this.group.groups.item(i);
				if(contentGrp.name.indexOf(DROPS) >= 0)	{
					featureContent = contentGrp.groups.itemByName(FEATURE_CONTENT)
					this.addSubFeatures(featureContent.groups.item(0).name,featureContent.groups.item(0));
				}
			}
		}
		
		public override function getBaseSubFeatures():void	{
			//super.getBaseSubFeatures();
			
			var iterator : IIterator = this.subFeatureList.keyIterator();
			var feature : IFeature;
			var key : String;
			while(iterator.hasNext())	{
				key = iterator.next();
				feature = this.subFeatureList.itemFor(key);
				feature.layout = this.layout;
				feature.directory = this.directory +  this.name + File.separator;
				feature.orientation = this.orientation;
				feature.name = key;
				feature.isInner = true;
				trace("\n\n\n");
				feature.initFeature();
				trace(feature.toString());
				trace("\n\n\n");
			}
		}
		public function badHide(isHide:Boolean,ftye:String):void	{
			this.group.visible = true;
			var dropGroups:Groups = (this.group.groups as Groups);
			var drag:Group = dropGroups.itemByName("drag") as Group;
			drag.visible = isHide;
			
			var iterator : IIterator = this.subFeatureList.keyIterator();
			var key : String;
			var feature : IFeature;
			
			var fdraw:DrawFeature;
			var slideShow : SlideShowFeature;
			var trgPano :TriggerablePanoramaFeature;
			var scl:ScaleFeature;
			
			while(iterator.hasNext())	{
				key = iterator.next();
				feature = this.subFeatureList.itemFor(key);
				if(feature.featureType == Configuration.TYPE_DRAW || feature.featureType == Configuration.TYPE_DRAWCLOSE)	{
					fdraw = feature as DrawFeature;
					fdraw.badHide(isHide,Configuration.TYPE_DRAW);
				}
				if(feature.featureType == Configuration.TYPE_SLIDESHOW)	{
					slideShow = feature as SlideShowFeature;
					slideShow.badHide(isHide,Configuration.TYPE_SLIDESHOW);
				}
				if(feature.featureType == Configuration.TYPE_TRIGGERABLEPANO){
					trgPano = feature as TriggerablePanoramaFeature;
					trgPano.badHide(isHide,Configuration.TYPE_TRIGGERABLEPANO);
				}
				if(feature.featureType == Configuration.TYPE_SCALE){
					scl = feature as ScaleFeature;
					scl.badHide(isHide,Configuration.TYPE_SCALE);
				}
			}
			
		}
		
		public override function set name(n:String):void {this._name = "am" + n.substring(n.indexOf("-"))};
		public override function get name():String { return _name;};
		
		public override function getJSON():Object	{
			//_json.subfeatures = super.getJSON();
			return _json;
		}
	}
}