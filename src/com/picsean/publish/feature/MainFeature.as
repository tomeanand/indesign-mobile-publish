package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.picsean.publish.utils.Configuration;
	
	import org.as3commons.collections.fx.LinkedMapFx;

	public class MainFeature extends BaseFeature
	{
		
		
		public function MainFeature(grp:Group)
		{
			this.type = Configuration.MAIN;
			super(grp);
		}
		
	
		
	}
}