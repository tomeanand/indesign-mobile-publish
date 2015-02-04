package com.picsean.publish.feature
{
	
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.Groups;
	import com.adobe.indesign.PageItem;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	
	
	public class CameraFeature extends BaseFeature
	{
		private static var MASK:String = "_mask";
		private static const FRONT_CAMERA :String = 'IsFrontCamera';
		private static const MASKS : String = "masks";
		private static const MASKSIN : String = "mask-";
		
		private var _json:Object;
		private var _group:Group;
		private var _drFArray:Array = [];
		private var _mPArray:Array = [];
		
		public function CameraFeature(grp:Group)
		{
			super(grp);
			_group = grp;
		}
	
		
		public override function initFeature():void
		{
			this.type = Configuration.TYPE_CAMERA;
			//super.getBaseSubFeatures();
			
			
			_json =new Object();
			_json= getLabels();
			_json.type = this.type;
			_json.orientation = PageUtil.setOrientationType(this.orientation);
			
			var trigger:PageItem = group.pageItems.itemByName("trigger");
			var capturebtn:PageItem = group.pageItems.itemByName("capturebtn");
			var camerarect:PageItem = group.pageItems.itemByName("camerarect");
			//var maskedimage:PageItem = camerarect;
			
			if(	this.skipFeature(trigger,capturebtn,camerarect ) )	{
				this.isCorrupted = true;
				return;
			}
			
			var tBound:BoundVO = new BoundVO(trigger as PageItem, group.parent as PageItem);
			var cptrBound:BoundVO = new BoundVO(capturebtn as PageItem, group.parent as PageItem);
			var cBound:BoundVO = new BoundVO(camerarect as PageItem, group.parent as PageItem);
			//var iBound:BoundVO = new BoundVO(maskedimage as PageItem, group.parent as PageItem);
			
			var pointTrigger:Object = tBound.createBound();
			var pointCapturebtn:Object = cptrBound.createBound();
			var pointCamerarect:Object = cBound.createBound();
			//var pointMaskedimage:Object = iBound.createBound();
			
			var maskImageName:String = this.directory + this.name + MASK + this.exetension;
			
			_json.cameraLocation = pointCamerarect.l;
			_json.image = this.serverURI + this.name +  MASK + this.exetension;
			_json.ImageLocation = pointCamerarect.l;
			//_json.ImageLocation = pointMaskedimage.l;
			_json.screenShotLocation = pointCamerarect.l;
			
			getCameraFeatures();
			getBaseSubFeatures();
			
			_json.subfeatures = super.getJSON();
			
			var backButtonLocation:String = pointTrigger.t;
			var imageCaptureButtonLocation:String = pointCapturebtn.l;
			//var imageCaptureframe:String = pointMaskedimage.l;
			var imageCaptureframe:String = pointCamerarect.l;
			
			var scrnSt:Object = new Object();
			scrnSt.backButtonLocation = backButtonLocation;
			scrnSt.imageCaptureButtonLocation = imageCaptureButtonLocation;
			scrnSt.imageCaptureframe = imageCaptureframe;
			
			var scrnStInfo:Array = new Array();
			scrnStInfo.push(scrnSt);
			
			_json.screenShotInfo = scrnStInfo;
			
			if(_mPArray.length > 0){
			
				for(var j:uint; j<_mPArray.length; j++)
				{
					delete _json[ _mPArray[j] ];  
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
			
			super.createDirectory();
			
			var exportMaskImage:File = new File(maskImageName);
			
			camerarect.exportFile(ExportFormat.PNG_FORMAT, exportMaskImage);
			
			
		}
		
		private function getCameraFeatures():void	{
			var contentGrp : Group;
			var featureContent : Group;
			var feature : IFeature;
			var mFeatureSet: Group;
			
			for(var i:Number = 0; i<this.group.groups.count(); i++)	{
				contentGrp = this.group.groups.item(i);
				if(contentGrp.name.indexOf(MASKS) >= 0)	{
					mFeatureSet = contentGrp;
					break;
				}
			}
			
			for(var j:uint = 0; j<mFeatureSet.groups.count(); j++){
				featureContent = mFeatureSet.groups.item(j);
				this.addSubFeatures(featureContent.name,featureContent);
				_drFArray.push(featureContent);
			}
		}
		
		public override function getBaseSubFeatures():void	{
			//super.getBaseSubFeatures();
			
			var iterator : IIterator = this.subFeatureList.keyIterator();
			var feature : IFeature;
			var key : String;
			var mCount:uint = 1;
			while(iterator.hasNext())	{
				key = iterator.next();
				feature = this.subFeatureList.itemFor(key);
				feature.layout = this.layout;
				feature.directory = this.directory +  this.name + File.separator;
				feature.orientation = this.orientation;
				feature.name = key;
				feature.isInner = true;
				BaseFeature(feature).maskPath = _json["CameraMask"+mCount];
				_mPArray.push("CameraMask"+mCount);
				trace("\n\n\n");
				feature.initFeature();
				mCount ++;
				//delete _json["CameraMask"+mCount];
				trace(feature.toString());
				trace("\n\n\n");
			}
		}
		
		private function getLabels():Object{
			var propstr:String = PageItem(_group).extractLabel(Configuration.LABEL);
			if(propstr.indexOf(Configuration.TYPE_CAMERA)<0){
				var obj:Object = new Object()
				obj[FRONT_CAMERA] = 'YES';
				
				return obj;
			}
			var data:Object = JSON.decode(propstr);
			return data;
		}
		
		public override function getJSON():Object	{
			_json.subfeatures = super.getJSON();
			return _json;
		}
		
		public function badHide(isHide:Boolean,ftye:String):void	{
			if(this.isCorrupted)	{ 
				isHide ? logger.error("Skipped feature "+this.type+" named "+this.name) : "";
				return;	
			}
			
			var content:Group
			for(var i:uint = 0; i<_drFArray.length; i++){
			content = _drFArray[i].groups.itemByName("contents") as Group;
			content.visible = isHide;
			}
			
		}
	}
}