package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	
	public class RelativePanoramaNew extends BaseFeature
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
		
		
		public function RelativePanoramaNew(grp:Group)
		{
			super(grp);
		}
		public override function initFeature():void	{
			panoList = new Array();
			
			//super.getBaseSubFeatures();
			this.type = Configuration.TYPE_RELATIVE_PANORAMA_NEW;
			_json = new Object();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			panoGroup = group.groups.itemByName(TYPE_RELATIVE_PANO_CLUB_FILTER);
			var panorama : PanoFeature;
			initSubfeatures();
			/*for(var i:Number = 0; i<panoGroup.groups.count(); i++)	{
				panorama = new PanoFeature( panoGroup.groups.item(i) );
				panorama.layout = this.layout;
				panorama.directory = this.directory + this.name + File.separator;
				panorama.orientation = this.orientation;
				panorama.name = panoGroup.groups.item(i).name;
				panorama.isRelative = true;
				var num:Number = 1 + i;
				panorama.acceleration = Number(num *5);
				panorama.initFeature();
				panoList.push(panorama.getJSON());
			}
			_json.subfeatures =panoList;*/
			_json.subfeatures = super.getJSON()
		}
		
		public function badHide(isHide:Boolean,ftye:String):void	{
			panoGroup.visible = isHide;
		}
		public override function set name(n:String):void {this._name = ("rp"+ n.substring( n.indexOf("-") ) )};
		public override function get name():String { return _name;};
		
		public override function getJSON():Object	{
			return _json;
		}
		public function getSubFeatures():Object	{
			return super.getJSON();
		}
		
		
		protected function initSubfeatures():void	{
			var iterator : IIterator = this.subFeatureList.keyIterator();
			var feature : IFeature;
			var key : String;
			while(iterator.hasNext())	{
				
				key = iterator.next();
				
				feature = this.subFeatureList.itemFor(key) as IFeature;
				
				feature.layout = this.layout;
				feature.directory = this.directory +  this.name + File.separator ;
				feature.orientation = this.orientation;
				feature.name = key;
				var pathstr :String = this.directory.substring(0,this.directory.lastIndexOf("/"));
				pathstr = pathstr.substring(pathstr.lastIndexOf("/")+2)
				PanoFeature(feature).pageNum=Number(pathstr);
				PanoFeature(feature).isRelative = true;
				feature.initFeature();
				
			}
		}		
		
	}
}