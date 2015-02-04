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
	import org.as3commons.collections.fx.LinkedMapFx;
	
	public class FlipBookFeature extends BaseFeature
	{
		
		private static const CURRUPTED_TYPE : String = "panoramaevent_automation";
		private static const EVENT_CONTENT_FILTER : String = "eventcontent";
		
		private static const OVERPANO :String = 'overPano';
		private static const ISACCELERARE :String = 'isAccelerate';
		private static const SDIRECTION :String = 'scrollingDirection';
		private static const TRIGGERS : String = "triggers";
		
		private var _json:Object;
		private var scrollthumb : PageItem, scrollbase  : PageItem;
		private var flips : Group;
		private var peventMap : LinkedMapFx = new LinkedMapFx();
		private var triggerPos : Object;
		private var featureDirPath : String;
		private var _name : String;
		private var flipBound : BoundVO;
		
		public function FlipBookFeature(grp:Group)
		{
			super(grp);
		}
		
		public override function initFeature():void	{
			var vbounds:BoundVO, pgbound:BoundVO;
			var boundObj:Object;
			var pgBoundObj:Object;
			var imageName : String;
			var exportImage : File;
			
			this.type = Configuration.TYPE_FLIP_BOOK;
			this.getBaseSubFeatures();
			
			
			_json = new Object();
			_json.type = CURRUPTED_TYPE
			
			scrollthumb = group.pageItems.itemByName("scrollthumb");
			scrollbase = group.pageItems.itemByName("scrollbase");
			flips = group.groups.itemByName("flips");
			
			if(!(group.parent is Group))
				vbounds = new BoundVO(scrollthumb as PageItem);
			else
				vbounds = new BoundVO(scrollthumb as PageItem,group.parent as PageItem);
			
			if(!(group.parent is Group))
				pgbound = new BoundVO(scrollbase as PageItem);
			else
				pgbound = new BoundVO(scrollbase as PageItem,group.parent as PageItem);
			
			boundObj = vbounds.createBound();
			pgBoundObj = pgbound.createBound();

			flipBound = new BoundVO(flips);
			
			imageName =  this.directory + this.name + this.exetension;
			
			_json.location = pgBoundObj.t;
			_json.trigger = pgBoundObj.t;
			//_json.contentsize ="{"+pgbound.width+","+pgbound.height+"}";
			_json.image   = this.serverURI + this.name + this.exetension;

			_json.subfeatures = super.getJSON();
			_json.orientation  =  BoundVO.getOrientationType(this.orientation);
			_json.eventsTrigger = new Object;
			
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
			
			//getting the events
			//assignEventMaps();
			//getting trigger positions
			//creating direcotry
			super.createDirectory();
			createFeatureDirectory()
			//publishing event items
			getEventTriggerItems(pgbound,vbounds);
			
			badHideInnerFeatures(false);
			
			exportImage = new File(imageName);

			scrollthumb.exportFile(ExportFormat.PNG_FORMAT, exportImage);
			
			badHideInnerFeatures(true);
			
		}
		/**
		 * Publishing inner features
		 * */
		public override function getBaseSubFeatures():void	{
			super.getBaseSubFeatures();
			
			/*var iterator : IIterator = this.subFeatureList.keyIterator();
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
			}*/
			
		}
		
		public function getSubFeatures():Object	{
			return super.getJSON();
		}
		public function badHide(isHide:Boolean,ftye:String):void	{
			this.group.visible = isHide;
			//contents.visible = isHide;
		}
		private function createFeatureDirectory():void	{
			featureDirPath = this.directory +  this.name + File.separator
			var pageDir : File = new File(featureDirPath);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		
		
		public override function getJSON():Object	{
			return this._json;
		}
		
		private function badHideInnerFeatures(isHide:Boolean):void	{
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
			
			flips.visible = isHide;
			
		}
		
		
		
		
		private function getEventTriggerItems(scrolBound:BoundVO, thumbBound:BoundVO):void	{
			var triggerFeatureList : Array = new Array();
			var scrollWidth : Number = (this.orientation == 'p' ? ( thumbBound.width - scrolBound.width)  :  thumbBound.height - scrolBound.height );
			var noPages : Number = flips.groups.length;
			var triggerDistance : Number = scrollWidth / noPages;
			var singleFpage:Group;
			for(var i:Number = 0; i<noPages; i++)	{
				singleFpage = flips.groups.item(i) as Group;
				triggerFeatureList.push(publishDraw( {item:singleFpage,name:'fp_'+(i)} , Math.round( Number(i*triggerDistance)+1) ));
			}
			_json.eventsTrigger = triggerFeatureList
			
			
		}
		
		
		private function publishDraw(item:Object, position:Number):Object	{
			var drawJson : Object;
			var commonDraw : CommonDrawFeature = new CommonDrawFeature(item.item,Configuration.TYPE_FLIP_BOOK);
			commonDraw.layout = this.layout;
			commonDraw.directory = this.featureDirPath;
			commonDraw.orientation = this.orientation;
			commonDraw.name = item.name;
			commonDraw.flipBound = this.flipBound;
				
			commonDraw.initFeature();
			drawJson = commonDraw.getJSON();
			drawJson.trigger_hit = position.toString();
			drawJson.style = 'none';
			drawJson.orientation  =  BoundVO.getOrientationType(this.orientation);
			drawJson.id = item.name;
			return drawJson;
		}
		
		public override function set name(n:String):void {this._name = ("pe"+ n.substring( n.indexOf("-") ) )};
		public override function get name():String { return _name;};
		
	}
}