package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.core.FeatureFactory;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	
	public class PanoFeature1 extends BaseFeature
	{
		
		private var _json:Object;
		private static const CURRUPTED_TYPE : String = "pano";
		private static const CURRUPTED_RELATIVE_TYPE : String = "RelativePanoNew";
		private var view : PageItem, contents  : PageItem;
		
		public var isRelative : Boolean = false;
		public var acceleration : Number =0;
		

		
		public function PanoFeature1(grp:Group)
		{
			super(grp);
		}
		
		
		public override function initFeature():void	{
			
			var vbounds:BoundVO, pgbound:BoundVO;
			var boundObj:Object;
			var imageName : String;
			var exportImage : File;
			
			this.type = Configuration.TYPE_PANO;
			this.getBaseSubFeatures();
			
			_json = new Object();
			_json.type = this.type//isRelative ? CURRUPTED_RELATIVE_TYPE : CURRUPTED_TYPE;
			
			//_json.type = this.type;
			view = group.pageItems.itemByName("view");
			contents = group.pageItems.itemByName("contents");
			
			if(!(group.parent is Group))
				vbounds = new BoundVO(view as PageItem);
			else
				vbounds = new BoundVO(view as PageItem,group.parent as PageItem);
			
			if(!(group.parent is Group))
				pgbound = new BoundVO(contents as PageItem);
			else
				pgbound = new BoundVO(contents as PageItem,group.parent as PageItem);
			
			boundObj = vbounds.createBound();
			imageName =  this.directory + this.name + this.exetension_JPG;
			
			_json.location = boundObj.l;
			_json.trigger = boundObj.t;
			_json.contentsize ="{"+pgbound.width+","+pgbound.height+"}";
			//_json.image   = this.serverURI + this.name + this.exetension;
			
			_json.subfeatures = super.getJSON();
			_json.scrolledValue = "{0,0}";
			_json.orientation  =  BoundVO.getOrientationType(this.orientation);
			if( PublishModel.getInstance().deviceSelected == Configuration.DEVICE_IPAD || Configuration.DEVICE_IPAD_RETINA || Configuration.DEVICE_IPHONE_4 || Configuration.DEVICE_IPHONE_5){
				_json.images = getImageList(pgbound);
				_json.images = new Array();
			}else{
				
				_json.image   = this.serverURI + this.name + this.exetension_JPG
			}
			
			_json.image   = this.serverURI + this.name + this.exetension_JPG
			_json.images.push(this.serverURI + this.name + this.exetension_JPG)
				
			//_json.cellSize = "{"+pgbound.width+","+Configuration.PANO_IMAGE_SPLIT_SIZE+"}"
			if( this.name == "rpanorama-1"){
				//PublishModel.getInstance().panoImagelist1.push(this.serverURI + this.name + this.exetension_JPG);
			}else if (this.name == "rpanorama-2"){
				//PublishModel.getInstance().panoImagelist2.push(this.serverURI + this.name + this.exetension_JPG);
			}
			if(isRelative){
				_json.scrollingDirection ="Y";
				_json.acclerationspeed = acceleration;
			}
			
			/**
			 * Checking whether its a AutoPanorama
			 * if found, the type will be changed into Autopanorama
			 * but the publishing flow will remain the same, only json changes
			 * */
			var propertyStr :String = this.group.extractLabel(Configuration.LABEL);
			var fproperty : Object;
			if(propertyStr.length > 10)	{
				fproperty = JSON.decode(propertyStr);
				if(fproperty.type == Configuration.TYPE_AUTO_PANORAMA)	{
					if(!fproperty.IsAfterVideo){
						_json[Configuration.PRPTY_SPEED] = fproperty[Configuration.PRPTY_SPEED];
						_json[Configuration.PRPTY_SVALUE] = fproperty[Configuration.PRPTY_SVALUE];
						_json[Configuration.PRPTY_SDIRECTION] = fproperty[Configuration.PRPTY_SDIRECTION];
						_json.type = Configuration.TYPE_AUTO_PANORAMA;
					}else{
						_json.IsAfterVideo = fproperty.IsAfterVideo;
					}
				}
			}
			
			
			super.createDirectory();
			
			badHideInnerFeatures(false);
			
			exportImage = new File(imageName);
			
			
			contents.exportFile(ExportFormat.jpg, exportImage);
			
			/**/ if(!isRelative){PublishModel.getInstance().panoImageList.push(exportImage.url);}
			badHideInnerFeatures(true);
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
		
		public function getSubFeatures():Object	{
			return super.getJSON();
		}
		public function badHide(isHide:Boolean,ftye:String):void	{
			this.group.visible = isHide;
			//contents.visible = isHide;
		}
		
		
		public override function getJSON():Object	{
			return this._json;
		}
		
		/*
		* todo better solution for this function. 
		*/
		private function getImageList(pg:BoundVO):Array{
			var arr:Array = new Array();
			if (pg.height > pg.width){
				var tileY:Number = Configuration.PANO_IMAGE_SPLIT_SIZE;
				var tilesV:uint = Math.ceil(pg.height / Configuration.PANO_IMAGE_SPLIT_SIZE);
				for (var i:Number = 0; i < tilesV; i++)
				{
					if( ( pg.height - (tileY  * i)) >= Configuration.PANO_IMAGE_SPLIT_SIZE){
					}else{
						var dataremaining :Number = pg.height -( tileY * i);
						_json.lastCellSize = "{"+pg.width+","+pg.height+"}"}
					//_json.lastCellSize = "{"+pg.width+","+dataremaining+"}"}
					
					_json.cellSize = "{"+pg.width+","+pg.height+"}"
					//_json.cellSize = "{"+pg.width+","+Configuration.PANO_IMAGE_SPLIT_SIZE+"}"
					var imgurl:String = this.serverURI +this.name+"_"+i + this.exetension_JPG ;
					arr.push(imgurl);
				}
			}else{
				var tileX:Number = Configuration.PANO_IMAGE_SPLIT_SIZE;
				var tilesX:uint = Math.ceil(pg.width / Configuration.PANO_IMAGE_SPLIT_SIZE);
				for (var i:Number = 0; i < tilesX; i++)
				{
					if( ( pg.width - (tileX  * i)) >= Configuration.PANO_IMAGE_SPLIT_SIZE){
					}else{
						var dataremaining :Number = pg.width - ( tileX * i);
						_json.lastCellSize = "{"+pg.width+","+pg.height+"}"}
					//_json.lastCellSize = "{"+dataremaining+","+pg.height+"}"}
					
					_json.cellSize = "{"+pg.width+","+pg.height+"}"
					var imgurl:String = this.serverURI +this.name+"_"+i + this.exetension_JPG ;
					arr.push(imgurl);}
			}
			return arr;	
		}
		
		protected function badHideInnerFeatures(isHide:Boolean):void	{
			var iterator : IIterator = this.subFeatureList.keyIterator();
			var feature : IFeature;
			while(iterator.hasNext())	{
				feature = this.subFeatureList.itemFor(iterator.next()) as IFeature;
				switch(feature.featureType)	{
					case Configuration.TYPE_DRAW : 				DrawFeature(feature).badHide(isHide,Configuration.TYPE_DRAW); break;
					case Configuration.TYPE_SLIDESHOW : 		SlideShowFeature(feature).badHide(isHide,Configuration.TYPE_SLIDESHOW); break;
					case Configuration.TYPE_SCROLL : 			ScrollFeature(feature).badHide(isHide,Configuration.TYPE_SCROLL); break;
					case Configuration.TYPE_ANIMBTN : 			AnimatedButtonFeature(feature).badHide(isHide,Configuration.TYPE_ANIMBTN); break;
					case Configuration.TYPE_SCALE : 			ScaleFeature(feature).badHide(isHide,Configuration.TYPE_SCALE); break;
					case Configuration.TYPE_PANORAMA : 			PanoramaFeature(feature).badHide(isHide,Configuration.TYPE_PANORAMA); break;
					case Configuration.TYPE_PANORAMA_EVENT : 	EventfullPanoramaFeature(feature).badHide(isHide,Configuration.TYPE_PANORAMA_EVENT); break;
					case Configuration.TYPE_TRIGGERABLEPANO : 	TriggerablePanoramaFeature(feature).badHide(isHide,Configuration.TYPE_TRIGGERABLEPANO); break;
					case Configuration.TYPE_RELATIVE_PANORAMA : RelativePanorama(feature).badHide(isHide,Configuration.TYPE_RELATIVE_PANORAMA); break;
					case Configuration.TYPE_TIMERJSON : 		TimerJsonFeature(feature).badHide(isHide,Configuration.TYPE_TIMERJSON); break;
					case Configuration.TYPE_DRAGIMAGE : 		DragImageFeature(feature).badHide(isHide,Configuration.TYPE_DRAGIMAGE); break;
					case Configuration.TYPE_ACCELEROMETERTRIGGER : AccelerometerTrigger(feature).badHide(isHide,Configuration.TYPE_ACCELEROMETERTRIGGER); break;
					case Configuration.TYPE_PANO : 			PanoFeature(feature).badHide(isHide,Configuration.TYPE_PANO); break;
				}
			}
		}
	}
}