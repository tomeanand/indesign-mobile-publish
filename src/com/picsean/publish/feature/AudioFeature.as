package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	public class AudioFeature extends BaseFeature
	{
		private var _json:Object;
		private static const AUDIO_FILE_NAME :String = 'audio-1.mp3';
		
		public function AudioFeature(grp:Group)
		{
			super(grp);
		}
		public override function initFeature():void{
			
			this.type = Configuration.TYPE_AUDIO_FEATURE;
			super.getBaseSubFeatures();
			
			_json = new Object();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			
			var content:PageItem = group.pageItems.itemByName("contents") as PageItem;
			
			if(	this.skipFeature(content) )	{
				logger.error("Skipped feature "+this.type+" named "+this.name);
				this.isCorrupted = true;
				return;
			}
			
			
			var cbounds:BoundVO;
			if(!(group.parent is Group)){
				cbounds = new BoundVO(content as PageItem);
			}
			else{
				cbounds = new BoundVO(content as PageItem,group.parent as PageItem);
			}
			var pointContent:Object = this.fixLocation(cbounds, new BoundVO(this.group as PageItem));
			_json.trigger = pointContent.t;
			//_json.location = pointContent.l;
			_json.repeatcount = 1;
			_json.volume = 1;
			if(group.pageItems.itemByName("trigger").isValid){
				_json.triggerable = 'YES';
			}else{
				_json.triggerable = 'NO';}
			var serveruri:String = PageUtil.getPublishServerAudioURI(directory) + AUDIO_FILE_NAME;
			_json.url =serveruri;
		}
		
		public override function getJSON():Object	{
			_json.subfeatures = super.getJSON();
			return _json;
		}
		
	}
}