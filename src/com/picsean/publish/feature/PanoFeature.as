package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.adobe.indesign.Groups;
	import com.adobe.indesign.PageItem;
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	import com.adobe.utils.StringUtil;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	
	import org.as3commons.collections.utils.NumericComparator;
	
	public class PanoFeature extends PanoramaFeature
	{
		
		
		private var _json:Object;
		private static const CURRUPTED_TYPE : String = "pano";
		private static const TYPE_VIDEOTRIGGER :String = "videotrigger";
		//public var type : String = "pano";
		
		//public var isRelative : Boolean = false;
		public var acceleration : Number =0;
		
		private var view : PageItem, contents  : PageItem;
		public var pageNum : Number;
		
		public function PanoFeature(grp:Group)
		{
			super(grp);
		}
		
		public override function initFeature():void	{
			this.type = CURRUPTED_TYPE;
			
			trace(this.group.name);
			view = group.pageItems.itemByName("view");
			contents = group.pageItems.itemByName("contents");
			var gpInner:Groups = Groups(this.group.groups.itemByName(Configuration.G_CONTENT).groups);
			var innerFeature:Object = getNestedFeature(gpInner);
			var i:Number = 0;
			for( i = 0; i< this.group.groups.length;i++)	{
				var pg:PageItem = group.groups.item(i);
				trace("----------->   "+pg.name)
			}
			for( i =0; i< gpInner.length; i++)
			{
				if(innerFeature.present)	{
					var innerlist : ArrayCollection = innerFeature.list;
					var sfeature : Object;
					for(var f:Number = 0; f<innerlist.length; f++)	{
						sfeature = innerlist[f];
						this.addSubFeatures(sfeature.name,sfeature.data as Group)
					}
				}
			}
			
			super.initFeature();
			
			_json = super.getJSON();
			_json.type = CURRUPTED_TYPE;
			_json.images = getImageList(newPageBound);
			
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
			
			
			_json.images = [];
			_json.image   = this.serverURI + this.name + this.exetension
			_json.images.push(this.serverURI + this.name + this.exetension);
			_json.cellSize = "{"+newPageBound.width+","+newPageBound.height+"}";
			_json.lastCellSize = "{"+newPageBound.width+","+newPageBound.height+"}"
				trace("page number:  "+this.pageNum);
				if(_json.subfeatures.length > 0 ){
					for( var k:int; k < _json.subfeatures.length ;k++){
						switch(_json.subfeatures[k].type)        {
							case Configuration.TYPE_SLIDESHOW : 
								_json.subfeatures[k].closeTriggerLocation = "{{240,0},{60,60}}"//jsonManipulation(_json.subfeatures[0].closeTriggerLocation);
								_json.subfeatures[k].location = "{{0,0},{768,1024}}"
								_json.subfeatures[k].trigger = jsonManipulation(_json.subfeatures[0].trigger);
								
								if (this.layout.device == Configuration.DEVICE_IPHONE_4){
									_json.subfeatures[k].closeTriggerLocation = "{{220,0},{100,100}}"
									_json.subfeatures[k].location = "{{0,0},{320,480}}"
								}
								else if (this.layout.device == Configuration.DEVICE_IPHONE_5){
									_json.subfeatures[k].closeTriggerLocation = "{{220,0},{100,100}}"
									_json.subfeatures[k].location = "{{0,0},{320,568}}"
								}
								else if (this.layout.device == Configuration.DEVICE_IPAD || Configuration.DEVICE_IPAD_RETINA){
									_json.subfeatures[k].closeTriggerLocation = "{{668,0},{100,100}}"
								}
								break;
							case Configuration.TYPE_VIDEO_FEATURE :
								_json.subfeatures[k].trigger = _json.subfeatures[k].location = jsonManipulation(_json.subfeatures[k].trigger)
								break;
							case TYPE_VIDEOTRIGGER :
								_json.subfeatures[k].trigger = _json.subfeatures[k].location = jsonManipulation(_json.subfeatures[k].trigger)
								break;
							
							case Configuration.TYPE_JUMP :
								_json.subfeatures[k].trigger = jsonManipulation(_json.subfeatures[k].trigger)
								break;
							
						}        
						
					}
					
					/*if(_json.subfeatures[0].type == Configuration.TYPE_SLIDESHOW){
					_json.subfeatures[0].closeTriggerLocation = "{{240,0},{60,60}}"//jsonManipulation(_json.subfeatures[0].closeTriggerLocation);
					_json.subfeatures[0].location = "{{0,0},{768,1024}}"
					_json.subfeatures[0].trigger = jsonManipulation(_json.subfeatures[0].trigger);
					
					if (this.layout.device == Configuration.DEVICE_IPHONE_4){
						//_json.subfeatures[0].closeTriggerLocation
						_json.subfeatures[0].closeTriggerLocation = "{{220,0},{100,100}}"
						_json.subfeatures[0].location = "{{0,0},{320,480}}"
					}else if (this.layout.device == Configuration.DEVICE_IPHONE_5){
						//_json.subfeatures[0].closeTriggerLocation
						_json.subfeatures[0].closeTriggerLocation = "{{220,0},{100,100}}"
						_json.subfeatures[0].location = "{{0,0},{320,568}}"
					}else if (this.layout.device == Configuration.DEVICE_IPAD || Configuration.DEVICE_IPAD_RETINA){
						//_json.subfeatures[0].closeTriggerLocation
						_json.subfeatures[0].closeTriggerLocation = "{{668,0},{100,100}}"
					}
					
					
					}
					
					else if (_json.subfeatures[0].type == Configuration.TYPE_JUMP){
						for(var k:int =0;k < _json.subfeatures.length ;k++){
						_json.subfeatures[k].trigger = jsonManipulation(_json.subfeatures[k].trigger);}//}
					}
					*/
					
				}
			
			//_json.cellSize = "{"+pgbound.width+","+Configuration.PANO_IMAGE_SPLIT_SIZE+"}"
			if( this.name == "rpanorama-1"){
				//PublishModel.getInstance().panoImagelist1.push(this.serverURI + this.name + this.exetension_JPG);
			}else if (this.name == "rpanorama-2"){
				//PublishModel.getInstance().panoImagelist2.push(this.serverURI + this.name + this.exetension_JPG);
			}
			
			if(isRelative){
				_json.scrollingDirection ="Y";
				if(this.group.name == "rpanorama-1"){
				_json.acclerationspeed = "6";
			}else{
				_json.acclerationspeed = "10";
			}}
			
		}
		
		private function jsonManipulation(str:String):String{
			var loc : Array = String(str).split("},{");
			var locPos : Array = String(loc[0]).substring(2).split(",");
			var sizePos : Array = String(loc[1]).substring(0, String(loc[1]).length-2 ).split(",");
			var newXpos : Number = Number( locPos[0] )
			var newYpos : Number = (((pageNum -1 )* newPageBound.height)+Number(locPos[1]));
			
			
			var newWidth :String = sizePos[0];
			var newHeight :String = sizePos[1];
			var location:String = "{{" + Number(newXpos) + "," + Number(newYpos) + "},{" + newWidth + "," + newHeight + "}}";
			return location;
		}
		
		private function getImageList(pg:BoundVO):Array{
			var arr:Array = new Array();
			var imgurl:String;
			var i:Number = 0;
			var dataremaining :Number;
			if (pg.height > pg.width){
				var tileY:Number = Configuration.PANO_IMAGE_SPLIT_SIZE;
				var tilesV:uint = Math.ceil(pg.height / Configuration.PANO_IMAGE_SPLIT_SIZE);
				for  (i = 0; i < tilesV; i++)
				{
					if( ( pg.height - (tileY  * i)) >= Configuration.PANO_IMAGE_SPLIT_SIZE){
					}else{
						dataremaining  = pg.height -( tileY * i);
						//_json.lastCellSize = "{"+pg.width+","+pg.height+"}"
					}
					//_json.lastCellSize = "{"+pg.width+","+dataremaining+"}"}
					
					//_json.cellSize = "{"+pg.width+","+pg.height+"}"
					//_json.cellSize = "{"+pg.width+","+Configuration.PANO_IMAGE_SPLIT_SIZE+"}"
					imgurl = this.serverURI +this.name+"_"+i + this.exetension ;
					arr.push(imgurl);
				}
			}else{
				var tileX:Number = Configuration.PANO_IMAGE_SPLIT_SIZE;
				var tilesX:uint = Math.ceil(pg.width / Configuration.PANO_IMAGE_SPLIT_SIZE);
				for ( i = 0; i < tilesX; i++)
				{
					if( ( pg.width - (tileX  * i)) >= Configuration.PANO_IMAGE_SPLIT_SIZE){
					}else{
						dataremaining = pg.width - ( tileX * i);
						_json.lastCellSize = "{"+pg.width+","+pg.height+"}"}
					//_json.lastCellSize = "{"+dataremaining+","+pg.height+"}"}
					
					_json.cellSize = "{"+pg.width+","+pg.height+"}"
					imgurl = this.serverURI +this.name+"_"+i + this.exetension;
					arr.push(imgurl);}
			}
			return arr;	
		}
		
		private function getNestedFeature(gp:Groups):Object	{
			// for safer side returning the object with boolean 
			var returnObj:Object = {present:false,list:new ArrayCollection()};
			if(gp == null){return returnObj;}
			for(var i:Number = 0; i<gp.count(); i++)	{
				//again checking the item is of a nested item
				if(Configuration.isNested(gp.item(i).name))	{
					returnObj.list.addItem({name:gp.item(i).name, data: gp.item(i) as Group})
					returnObj.present = true;
				}
			}
			return returnObj;
		}
	}
}