package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;
	
	public class RelativePanorama extends BaseFeature
	{

		private static const TYPE_RELATIVE_PANO : String = "relativePano";
		private static const TYPE_RELATIVE_PANO_GROUPS : String = "rpanorama";
		private static const TYPE_RELATIVE_PANO_CLUB_FILTER : String = "clubedPano";
		private static const G_GROUP_CONTENT : String = "view";
		private static const G_GROUP_VIEW : String = "content";	
		
		private var _name : String;
		private var _json : Object;
		private var panoGroup : Group;
		private var panoList :Array;
		
		public function RelativePanorama(grp:Group)
		{
			super(grp);
		}
		
		public override function initFeature():void	{
			panoList = new Array();
			this.type = Configuration.TYPE_RELATIVE_PANORAMA;
			//var subfeature_array:Array = new Array();
			
			panoGroup = group.groups.itemByName(TYPE_RELATIVE_PANO_CLUB_FILTER);
			var panorama : PanoramaFeature;
			for(var i:Number = 0; i<panoGroup.groups.count(); i++)	{
				panorama = new PanoramaFeature( panoGroup.groups.item(i) );
				panorama.layout = this.layout;
				panorama.directory = this.directory + this.name + File.separator;
				panorama.orientation = this.orientation;
				panorama.name = panoGroup.groups.item(i).name;
				panorama.isRelative = true;
				panorama.initFeature();
				panoList.push(panorama.getJSON());
				//subfeature_array.push(feature.getJSON());
			}
		}
		public function badHide(isHide:Boolean,ftye:String):void	{
			panoGroup.visible = isHide;
		}
		public override function set name(n:String):void {this._name = ("rp"+ n.substring( n.indexOf("-") ) )};
		public override function get name():String { return _name;};
		
		public override function getJSON():Object	{
			return panoList as Object;
		}
		
		
	}
}