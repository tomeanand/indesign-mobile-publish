package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	import flash.filesystem.File;
	
	public class VideoFeature extends BaseFeature
	{
		
		private var _json:Object;
		private static const VIDEO_FILE_NAME :String = 'video-1.mov';
		private static const VIDEO_EXTN :String = '.mp4';
		private static const TYPE_VIDEOTRIGGER :String = "videotrigger";
		
		public function VideoFeature(grp:Group)
		{
			super(grp);
		}
		
		public override function initFeature():void{
			
			this.type = Configuration.TYPE_VIDEO_FEATURE;
			super.getBaseSubFeatures();
			
			_json = new Object();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			
			var content:PageItem = group.pageItems.itemByName("contents") as PageItem;
			var cbounds:BoundVO;
			if(!(group.parent is Group)){
				cbounds = new BoundVO(content as PageItem);
			}
			else{
				cbounds = new BoundVO(content as PageItem,group.parent as PageItem);
			}
			var pointContent:Object = this.fixLocation(cbounds, new BoundVO(this.group as PageItem));
			_json.trigger = pointContent.t;
			_json.location = pointContent.l;
			_json.style ="none";
			_json.isVideoRepeat = "NO";
			
				
			
			
			
			if(group.pageItems.itemByName("trigger").isValid){
				_json.type = TYPE_VIDEOTRIGGER
				_json.autoplay = 'false';
			}else{
			_json.autoplay = 'true';}
			
			if(group.pageItems.itemByName("fullscreen").isValid){
				_json.style ="fullscreen";
				_json.autoplay = 'false';
			}else{
				}
			
			var serveruri:String = this.serverURI + this.group.name + VIDEO_EXTN;
			_json.url =serveruri;
			var tempfolder :File = new File(directory);
			if(!tempfolder.exists){tempfolder.createDirectory();}
			
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
		
		public override function getJSON():Object	{
			_json.subfeatures = super.getJSON();
			return _json;
		}
	}
}