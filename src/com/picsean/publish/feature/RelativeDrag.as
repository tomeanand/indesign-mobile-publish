package com.picsean.publish.feature
{
	
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.Groups;
	import com.adobe.indesign.PageItem;
	import com.adobe.indesign.PageItems;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.model.vo.PageVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	import flash.filesystem.File;
	//
	public class RelativeDrag extends BaseFeature
	{
		private var _group:Group;
		private var _json:Object;
		private static const SUBTYPE:String = 'subtype';
		private var featureContent : Group;
		private static const WCONTENT :String = "wrongcontent";
		private var _subfeature_array:Array;
		//
		public function RelativeDrag(grp:Group)
		{
			super(grp);
			this._group = grp;
		}
		public override function initFeature():void{
			this.type = Configuration.TYPE_RELATIVE_DRAG;
			var feature:IFeature;
			var subfeature_array:Array = new Array();
			_json = new Object();
			_subfeature_array = new Array();	
			///
			var cbounds:BoundVO;
			if(!(group.parent is Group)){
				cbounds = new BoundVO(group as PageItem);
			}
			else	{
				cbounds = new BoundVO(group as PageItem,(group.parent) as PageItem);
			}
			var pointContent:Object = this.fixLocation(cbounds, new BoundVO(this.group as PageItem))
			_json.location = pointContent.l;
			_json.type = type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			_json.range = "{50,50}";
			
			
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
			
			createDirectory();
			generateImages();
			//
			getSubFeatures();
		}
		//
		private function getSubFeatures():void{
			var subFeat:Groups = (this.group as Group).groups;
			for (var i:int=0; i<subFeat.length; i++){
				var item:Group = subFeat.item(i) as Group;
				if(item.name == WCONTENT){
				}else{
					var feature:IFeature;
					feature = new DrawFeature(item as Group);
					feature.layout = this.layout;
					feature.directory = this.directory;
					feature.name = item.name;
					feature.orientation = this.orientation;
					feature.initFeature();
					_subfeature_array.push(feature.getJSON());	
				}
			}
			_json.subfeatures = _subfeature_array;
		}
		public override function createDirectory():void{
			var pageDir : File = new File(this.directory+this.name);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		private function generateImages():void{
			var drag:Group = group.groups.itemByName("wrongcontent");
			var exportf:File = new File(this.directory+this.name+File.separator+drag.name+this.exetension);
			drag.exportFile(ExportFormat.PNG_FORMAT, exportf);
			_json.image =this.serverURI +this.name+File.separator+ drag.name + this.exetension;
		}
		public function badHide(isHide:Boolean,ftye:String):void{
			this.group.visible = true;
			var subFeat:Groups = (this.group as Group).groups;
			for (var i:int=0; i<subFeat.length; i++){
				var item:Group = subFeat.item(i) as Group;
				if(item.name == WCONTENT){
					item.visible = isHide;
				}else{
					var content:Group = item.groups.itemByName("contents") as Group;
					var trigger:Group = item.groups.itemByName("trigger") as Group;
					var triggerGroup:Group = trigger.groups.itemByName("selected");
					content.visible = isHide;
					triggerGroup.visible = isHide;
				}
			}
		}
		private function triggerLocation(g:Group,name:String):String{
			var bounds:Array = group.visibleBounds as Array;
			var xpos:int = bounds[1] / layout.ratio;
			var ypos:int = bounds[0] / layout.ratio;
			var tbounds:BoundVO;
			var drag:PageItem=g.pageItems.itemByName(name);
			tbounds = new BoundVO(drag as PageItem,group as PageItem);
			var trigger:String = "{{" + Number(tbounds.xpos+xpos) + "," + Number(tbounds.ypos+ypos) + "},{" + tbounds.width + "," + tbounds.height + "}}";;	
			return(trigger);
		}
		public override function getJSON():Object	{
			return _json;
		}
	}
}