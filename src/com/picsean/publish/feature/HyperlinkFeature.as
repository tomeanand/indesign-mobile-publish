package com.picsean.publish.feature
{
	import com.adobe.indesign.PageItem;
	import com.picsean.publish.utils.Configuration;

	public class HyperlinkFeature extends BaseFeature
	{
		public function HyperlinkFeature()
		{
			super();
			this.type = Configuration.TYPE_IMAGEHYPERLINK;
		}
		
		public override function getProperty(pg:PageItem,id:Number):Object	{
			return CommonFeatures.getLinks(pg,id);
		}
	}
}