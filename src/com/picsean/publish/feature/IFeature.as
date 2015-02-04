package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.picsean.publish.model.LayoutVO;
	
	import org.as3commons.collections.fx.LinkedMapFx;

	public interface IFeature
	{
		
		function getBaseSubFeatures():void // getting all base sub features ie; Hyperlink, Video, Text
		function addSubFeatures(fName:String,group:Group):void;
		function hasSubfeatures():Boolean;
		function getJSON():Object
		function initFeature():void;
		
		function get subFeatureList():LinkedMapFx;
		function get featureType():String
			
		function set directory(dir:String):void;
		function get directory():String;
		
		function set orientation(type:String):void;
		function get orientation():String;
		
		function set name(n:String):void;
		function get name():String;

		function set layout(l:LayoutVO):void;
		function get layout():LayoutVO;

		function set isInner(isinner:Boolean):void;
		function get isInner():Boolean;
		
		function set isCorrupted(corrupted:Boolean):void;
		function get isCorrupted():Boolean;
		
		function toString():String;
		
	}
}