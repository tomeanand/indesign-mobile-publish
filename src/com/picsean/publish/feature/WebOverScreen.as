package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	
	public class WebOverScreen extends BaseFeature
	{
		private var _json:Object;
		
		public function WebOverScreen(grp:Group)
		{
			this.type = Configuration.TYPE_WEBVIEW;
			super(null);
		}
		public override function initFeature():void	{
			// make visibility false for the item, beccause
			//where ever the area is the webview iframe loads
			_json = new Object();
			this.boundvo = new BoundVO(this.group as PageItem);
			var bound:Object = this.boundvo.createBound();
			_json.location = bound.l; _json.trigger = bound.t;
			
			var allPgItem:Array = group.allPageItems as Array;
			var pageItem:PageItem;
			var propertyString:String;
			var convertedData:Object;
			for(var i:int = 0; i<allPgItem.length; i++)	{
				pageItem = allPgItem[i] as PageItem;
				
				//String manipulation
				//best case scenario, string should be  "hyperlink-url=http://yahoo.com;"
				propertyString = pageItem.extractLabel(Configuration.LABEL);
				if(propertyString.length>4 && propertyString.indexOf(Configuration.TYPE_WEBVIEW)>0)	{
					convertedData = JSON.decode(propertyString);
					_json.url = convertedData.url;
					break;
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
			
				
		}
			
		public override function getJSON():Object	{
			return _json;
		}
	}
}