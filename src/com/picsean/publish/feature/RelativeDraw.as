package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.Groups;
	import com.adobe.indesign.PageItem;
	import com.adobe.indesign.PageItems;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	import flash.filesystem.File;
	
	public class RelativeDraw extends BaseFeature
	{
		private var _json:Object;
		private var _subfeature_array:Array
		private static const WCONTENT :String = "wrongcontent";
		
		public function RelativeDraw(grp:Group)
		{
			super(grp);
		}
		
		public override function initFeature():void{
			this.type = Configuration.TYPE_RELATIVE_DRAW;
			super.getBaseSubFeatures();
			var feature:IFeature;
			_subfeature_array = new Array();	
			_json = new Object();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			var content:PageItem=group.pageItems.itemByName(WCONTENT);
			_json.isMultidraw = "NO";
			
			
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
			getSubFeatures();
		}
		
		private function generateImages():void{
			var content:Group =group.groups.itemByName(WCONTENT) as Group;
			var exportf:File=new File(directory+this.name+File.separator+content.name+this.exetension);
			content.exportFile(ExportFormat.PNG_FORMAT, exportf);
			_json.wrongURL =this.serverURI +this.name+File.separator+ content.name + this.exetension;
		}
		public override function createDirectory():void{
			var pageDir : File = new File(this.directory+this.name);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		
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
		public override function getJSON():Object	{
			return _json;
		}
	}
}