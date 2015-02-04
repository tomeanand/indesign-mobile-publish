package com.picsean.publish.feature
{
	import com.adobe.indesign.Document;
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.Page;
	import com.adobe.indesign.Spread;
	import com.picsean.publish.model.LayoutVO;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	
	public class ConvertedPanoramaFeature extends PanoramaFeature
	{
		public var panoType : String;
		public var page : Page;
		private static const CURRUPTED_TYPE : String = "panaroma";
		
		public static const PANO_MUTLI : String = "MultiplePano";
		public static const PANO_DEFAULT : String = "DefaultPano";
		
		private var _json : Object;
		
		public function ConvertedPanoramaFeature(type : String, panoType : String,  page : Page, name : String, directoryUrl : String, orient : String, lvo : LayoutVO)
		{
			super(null);
			this.type = Configuration.TYPE_PANORAMA;
			this.panoType = panoType; 
			this.layout = lvo;
			this.page = page;
			this.name = name;
			this.directory = directoryUrl;
			this.orientation = orient;
			
			this.subFeatures = new LinkedMapFx();
			this.baseSubFeatures = new LinkedMapFx();
		}
		
		public override function initFeature():void	{
			var imageName : String;
			
			_json = new Object();
			_json.type = CURRUPTED_TYPE
			
			getBaseSubFeatures();
			
			imageName = this.directory + this.name + this.exetension_JPG;
			_json.image = this.serverURI + this.name + this.exetension_JPG;
			_json.location = "{{0,0},{"+ int(layout.width ) + "," + int(layout.height) + "}}";
			_json.trigger = _json.location;
			_json.contentsize = "{"+ int(layout.pageDimension.x / layout.ratio ) +"," + int(layout.pageDimension.y / layout.ratio) + "}"; // @Bug id - 234
			_json.subfeatures = getBaseJSON();
			_json.orientation = BoundVO.getOrientationType(this.orientation);
			_json.scrolledValue = "{0,0}";
			
			super.createDirectory();
			super.badHideInnerFeatures(false);
			
			printPanoPage();
			
			super.badHideInnerFeatures(true);
			
			
			
		}
		
		public function printPano():void	{
			super.badHideInnerFeatures(false);
			printPanoPage();
			super.badHideInnerFeatures(true);
		}

		public override function getJSON():Object	{
			return this._json;
		}
		
		public override function badHide(isHide:Boolean, ftye:String):void	{
			trace("\n\n\n NOTHING TO HIDE SO FAR "+this.panoType+" \n\n\n")
			var iterator : IIterator = this.subFeatureList.keyIterator();
			var feature : IFeature;
			var key : String;
			while(iterator.hasNext())	{
				key = iterator.next();
				feature = this.subFeatureList.itemFor(key);
				BaseFeature(feature).group.visible = isHide;
			}
		}
		
		public function addBaseSubFeatures(key : String, feature : IFeature):void	{
			this.baseSubFeatures.add(key, feature );
		}
		public  function addToSubFeature(key : String, feature : IFeature):void	{
			this.subFeatureList.add(key,feature);
		}
		
		private function printPanoPage():void	{
			var doc : Document = (page.parent as Spread).parent;
			var xportFile : File =  new File(super.directory + this.name + this.exetension_JPG);
			
			
			doc.exportFile(ExportFormat.jpg, xportFile, false);
		}
		/**
		 * Publishing inner features
		 * */
		public override function getBaseSubFeatures():void	{
			//super.getBaseSubFeatures();
			
			var iterator : IIterator = this.subFeatureList.keyIterator();
			var feature : IFeature;
			var key : String;
			while(iterator.hasNext())	{
				key = iterator.next();
				feature = this.subFeatureList.itemFor(key);
				feature.layout = this.layout;
				feature.directory = this.directory +  this.name + File.separator ;
				feature.orientation = this.orientation;
				feature.name = key;
				trace("\n\n\n");
				feature.initFeature();
				trace(feature.toString());
				trace("\n\n\n");
			}
			
		}	
		private function getBaseJSON():Array	{
			var jsonList : Array = new Array();
			var feature : IFeature;
			
			
			if(baseSubFeatures.size > 0)	{
				var iterator : IIterator = this.baseSubFeatures.keyIterator();
				while (iterator.hasNext()) {
					feature = baseSubFeatures.itemFor(iterator.next()) as IFeature;
					jsonList.push(feature.getJSON());
				}
			}
			
			if(hasSubfeatures())	{
				iterator = subFeatures.keyIterator();
				while (iterator.hasNext()) {
					feature = subFeatures.itemFor(iterator.next()) as IFeature;
					jsonList.push(feature.getJSON());
				}
			}
			
			
			return jsonList;
		}
		/*private function badHideInnerFeatures(isHide:Boolean):void	{
			var iterator : IIterator = this.subFeatureList.keyIterator();
			var feature : IFeature;
			while(iterator.hasNext())	{
				feature = this.subFeatureList.itemFor(iterator.next()) as IFeature;
				switch(feature.featureType)	{
					case Configuration.TYPE_DRAW : DrawFeature(feature).badHide(isHide,Configuration.TYPE_DRAW); break;
					case Configuration.TYPE_SLIDESHOW : SlideShowFeature(feature).badHide(isHide,Configuration.TYPE_SLIDESHOW); break;
					case Configuration.TYPE_SCROLL : ScrollFeature(feature).badHide(isHide,Configuration.TYPE_SCROLL); break;
					case Configuration.TYPE_TRIGGERABLEPANO : TriggerablePanoramaFeature(feature).badHide(isHide,Configuration.TYPE_TRIGGERABLEPANO); break;
				}
			}
		}*/
		
	}
}