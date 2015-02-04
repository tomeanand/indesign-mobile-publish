package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.Groups;
	import com.adobe.indesign.PageItem;
	import com.adobe.indesign.PageItems;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.core.FeatureFactory;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.model.vo.PageVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	import flash.filesystem.File;
	
	public class DragImageFeature extends BaseFeature
	{
		
		private var _json:Object;
		private var subJson:Object;
		private var checklabel:Object;
		private var _currentVisibleState:Boolean = false;
		private var explicitType:String;
		private static const SUBTYPE:String = 'subtype';
		private var _group:Group
		private var pageItem:PageItem;
		private var itemCount:int;
		private static const CURRUPTED_TYPE : String = "dragImage";
		//
		public function DragImageFeature(grp:Group)
		{
			super(grp);
			this._group = grp;
		}
		public override function initFeature():void{
			this.type = Configuration.TYPE_DRAGIMAGE;
			super.getBaseSubFeatures();
			var feature:IFeature;
			var subfeature_array:Array = new Array();
			_json = new Object();
			checklabel = new Object();
			//
			createDirectory();
			//
			var dropGroups:Groups = (group.groups as Groups)
			for (var i:int=0; i<dropGroups.length; i++){
			if(dropGroups.item(i).name.indexOf("drop")>-1){
				checklabel = getLabels(dropGroups.item(i));
			if(checklabel.type == null ){
				subJson = new Object();
				subJson.type = Configuration.TYPE_DRAW;
				subJson.closetrigger = "YES";
				subJson.orientation = PageUtil.setOrientationType(this.orientation);
				subJson.location = triggerLocation(dropGroups.item(i),"dragcontent");
				subJson.trigger = triggerLocation(dropGroups.item(i),"dragtrigger");
				subJson.image = generateContentImages(dropGroups.item(i));
				subfeature_array.push(subJson);	
			}else if(checklabel.type == Configuration.TYPE_AUDIO ){
				var audiofeature:CommonFeature;
				audiofeature = CommonFeatures.getAudio(pageItem,itemCount,this.directory,this.orientation,this.layout);
				var aObject:Object = audiofeature.getJSON();
				aObject.trigger = triggerLocation(dropGroups.item(i),"dragtrigger");
			    subfeature_array.push(aObject);
			} else if(checklabel.type == Configuration.TYPE_VIDEOTRIGGER || checklabel.type == Configuration.TYPE_VIDEO){
				var videofeature:CommonFeature;
				videofeature = CommonFeatures.getVideo(pageItem,itemCount,this.directory,this.orientation,this.layout);
				var vObject:Object = videofeature.getJSON();
				vObject.location = triggerLocation(dropGroups.item(i),"dragcontent");
				vObject.trigger = triggerLocation(dropGroups.item(i),"dragtrigger");
				vObject.type = "video";
				subfeature_array.push(vObject);
			} 
			}
			}
			
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
			
			_json.type = CURRUPTED_TYPE;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			_json.subfeatures = subfeature_array;
			_json.location = triggerLocation(this.group,"drag");
			_json.triggerRange = "{50,50}"
			generateImages();
		}
		//
		private function getLabels(g:Group):Object{
			var dragcontent:PageItem=g.pageItems.itemByName("dragcontent");
			var allPgItem:Array = dragcontent.allPageItems as Array;
			
			for(var i:int = 0; i<allPgItem.length; i++)	{
				pageItem = allPgItem[i] as PageItem;
				var propstr:String = pageItem.extractLabel(Configuration.LABEL);
				if(propstr.length>0){
					itemCount = i;
					break;
				}
			}
			if(propstr == "" ){
				var obj:Object = new Object();
				return obj;
			}
			//
			var data:Object = JSON.decode(propstr);
			return data;
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

		
		private function generateImages():void{
			var drag:Group = group.groups.itemByName("drag") as Group;
			var exportf:File = new File(this.directory+this.name+File.separator+drag.name+this.exetension);
			drag.exportFile(ExportFormat.PNG_FORMAT, exportf);
			_json.image =this.serverURI +this.name+File.separator+ drag.name + this.exetension;
		}
		private function generateContentImages(g:Group):String{
			var content:PageItem=g.pageItems.itemByName("dragcontent");
			var exportf:File=new File(this.directory+this.name+File.separator+content.name+this.exetension);
			content.exportFile(ExportFormat.PNG_FORMAT, exportf);
			var path:String = this.serverURI +this.name+File.separator+ content.name + this.exetension;
			return path;
		}
		public override function createDirectory():void{
			var pageDir : File = new File(this.directory+this.name);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		public function badHide(isHide:Boolean,ftye:String):void	{
			this.group.visible = true;
			var dropGroups:Groups = (this.group.groups as Groups);
			var drag:Group = dropGroups.itemByName("drag") as Group;
			drag.visible = isHide;
			for (var i:int=0; i<dropGroups.length; i++){
				if(dropGroups.item(i).name.indexOf("drop")>-1){
					var drop:Group = dropGroups.item(i) as Group;
					var content:Group = drop.groups.itemByName("dragcontent") as Group;
					content.visible = isHide;
				}}
		}
		public override function getJSON():Object	{
			//_json.subfeatures = super.getJSON();
			return _json;
		}
	}
}