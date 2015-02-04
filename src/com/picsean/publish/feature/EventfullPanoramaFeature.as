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
	
	public class EventfullPanoramaFeature extends BaseFeature
	{
		
		private static const CURRUPTED_TYPE : String = "panoramaevent_automation";
		private static const EVENT_CONTENT_FILTER : String = "eventcontent";
		
		private static const OVERPANO :String = 'overPano';
		private static const ISACCELERARE :String = 'isAccelerate';
		private static const SDIRECTION :String = 'scrollingDirection';
		private static const TRIGGERS : String = "triggers";

		private var _json:Object;
		private var view : PageItem, contents  : PageItem;
		private var peventMap : LinkedMapFx = new LinkedMapFx();
		private var triggerPos : Object;
		private var featureDirPath : String;
		private var _name : String;
		
		public function EventfullPanoramaFeature(grp:Group)
		{
			super(grp);
		}
		
		public override function initFeature():void	{
			var vbounds:BoundVO, pgbound:BoundVO;
			var boundObj:Object;
			var imageName : String;
			var exportImage : File;
			
			this.type = Configuration.TYPE_PANORAMA_EVENT;
			this.getBaseSubFeatures();
			
			
			_json = new Object();
			_json.type = CURRUPTED_TYPE
				
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
			_json.image   = this.serverURI + this.name + this.exetension_JPG;
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
			assignEventMaps();
			//getting trigger positions
			//creating direcotry
			super.createDirectory();
			createFeatureDirectory()
			//publishing event items
			getEventTriggerItems();
			
			badHideInnerFeatures(false);
			
			exportImage = new File(imageName);
			contents.exportFile(ExportFormat.jpg, exportImage);
			
			badHideInnerFeatures(true);
			
		}
		/**
		 * Publishing inner features
		 * */
		public override function getBaseSubFeatures():void	{
			//super.getBaseSubFeatures();
			
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
			
			iterator = this.peventMap.keyIterator();
			var group:Group;
			while(iterator.hasNext())	{
				group = Object(peventMap.itemFor(iterator.next())).item as Group;
				group.visible = isHide;
			}
			
		}
		
		
		private function assignEventMaps():void	{
			var gp : Group;
			var propertyName : String = "";
			var propertyData : Object;
			var itemJson : Object; 
			var type : String = "draw";
			var commonFeature : CommonFeature;
			var bounds : BoundVO
			
			for(var i:Number = 0; i<group.groups.count(); i++)	{
				
				gp = group.groups.item(i) as Group;
				propertyData = this.serverURI + this.name  +File.separator + gp.name + this.exetension;
				type = "draw";
				bounds = new BoundVO(gp as PageItem);
				if(gp.name.indexOf(EVENT_CONTENT_FILTER) >=0 )	{
					try	{
						
						if(gp.extractLabel(Configuration.LABEL).length >10)	{
							propertyName = gp.extractLabel(Configuration.LABEL);
							itemJson = JSON.decode(propertyName); 
							type = itemJson.type;
							
							commonFeature = (type == Configuration.TYPE_AUDIO ? CommonFeatures.getAudio(gp as PageItem, Math.round(Math.random()*20),this.directory, this.orientation,this.layout) : 
								CommonFeatures.getVideo(gp as PageItem, Math.round(Math.random()*20),this.directory, this.orientation,this.layout));
							
							propertyData = commonFeature.getJSON();
						}
						
					}catch(error:Error)	{
						trace("NO PROPERTY");
					}
					peventMap.add(gp.name,{data:propertyData, item: gp,type : type});
				}
			}
		}
		
		private function getEventTriggerItems():void	{
			var triggerFeatureList : Array = [];
			var fPropertyStr : String = "" 
			var fPropertyJSON :Object;
			var eventContent : Object;
			try	{
				if(this.group.extractLabel(Configuration.LABEL))	{
					fPropertyStr = this.group.extractLabel(Configuration.LABEL);
				}
			}
			catch(error:Error)	{
				
			}
			//
			if(fPropertyStr.length > 10)	{
				fPropertyJSON = JSON.decode(fPropertyStr);
				
				_json[ISACCELERARE] = fPropertyJSON[ISACCELERARE];
				_json[OVERPANO] = fPropertyJSON[OVERPANO];
				_json[SDIRECTION] = fPropertyJSON[SDIRECTION];
				
				var triggerPos : Object = fPropertyJSON[TRIGGERS];
				
				var cursor : IIterator = this.peventMap.keyIterator();
				var jsonData : Object;
				var key : String;
				var tpos : Object;
				var count : Number = 0;
				while(cursor.hasNext())	{
					key = cursor.next();
					tpos = (triggerPos[key] != null ? triggerPos[key] :  count);
					count ++
					eventContent = this.peventMap.itemFor(key);
					if(eventContent.type == "draw")	{
						triggerFeatureList.push( publishDraw(eventContent,Number(tpos)) );
					}
					else	{
						jsonData = eventContent.data;
						jsonData.trigger_hit = tpos.toString();
						triggerFeatureList.push (jsonData)
					}
					
				}
				
				_json.eventsTrigger = triggerFeatureList
			}
		}
		
		
		private function publishDraw(item:Object, position:Number):Object	{
			var drawJson : Object;
			var commonDraw : CommonDrawFeature = new CommonDrawFeature(item.item);
			commonDraw.layout = this.layout;
			commonDraw.directory = this.featureDirPath;
			commonDraw.orientation = this.orientation;
			commonDraw.name = item.item.name;
			
			commonDraw.initFeature();
			drawJson = commonDraw.getJSON();
			drawJson.trigger_hit = position.toString();
			return drawJson;
		}
		
		public override function set name(n:String):void {this._name = ("pe"+ n.substring( n.indexOf("-") ) )};
		public override function get name():String { return _name;};
		
	}
}