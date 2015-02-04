package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.core.FeatureFactory;
	import com.picsean.publish.model.vo.PageVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	public class TimerJsonFeature extends BaseFeature
	{
		private var _json:Object;
		private var _group:Group
		
		private static const SUBTYPE:String = 'subtype';
		
		public function TimerJsonFeature(grp:Group)
		{
			super(grp);
			this._group = grp;
		}
		
		public override function initFeature():void{
			this.type = Configuration.TYPE_TIMERJSON
			super.getBaseSubFeatures();
			var feature:IFeature;
			var subfeature_array:Array = new Array();
			_json = new Object();
			_json= getLabels();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			if(_json[SUBTYPE] == Configuration.TYPE_DRAWCLOSE ||_json[SUBTYPE] == Configuration.TYPE_DRAW ){
				feature = new DrawFeature(this._group);
					feature.layout = this.layout;
					feature.directory = this.directory;
					feature.name = _json[SUBTYPE];
					feature.orientation = this.orientation;
					feature.initFeature();
					subfeature_array.push(feature.getJSON());
					
			} else if(_json[SUBTYPE] == Configuration.TYPE_PANORAMA){
				feature = new PanoramaFeature(this._group);
					feature.layout = this.layout;
					feature.directory = this.directory;
					feature.orientation = this.orientation;
					feature.name = _json[SUBTYPE];
					feature.initFeature();
					subfeature_array.push(feature.getJSON());}
			_json.subfeatures = subfeature_array;
			
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
			
			delete _json[SUBTYPE];
			
				}
		
		private function getLabels():Object{
			var propstr:String = PageItem(_group).extractLabel(Configuration.LABEL);
			if(propstr.indexOf(Configuration.TYPE_DRAW_MULTI_TIMER)<0){
				var obj:Object = new Object();
				return obj;
			}
			var data:Object = JSON.decode(propstr);
			return data;
		}
		
		public function badHide(isHide:Boolean,ftye:String):void{
			this._group.visible = isHide;
		}
		
		public override function getJSON():Object	{
			return _json;
		}
		
	}
}