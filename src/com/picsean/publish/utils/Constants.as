package com.picsean.publish.utils
{
	public class Constants
	{
		//public static const ROOT_URL : String = "http://localhost/analytics_dashboard/index.php/api/";
		public static const IDML_ROOT : String = "http://www.picsean.com/pubplus/images/publishers/";
		public static const ROOT_URL : String = "http://www.picsean.com/testdashboard/api/";
		public static const MP : String = "POST";
		public static const MG : String = "GET";
		
		public static const LOGIN : String = "login";
		public static const MAGS : String = "magazines";
		public static const EDITION : String = "editions";
		public static const ISSUE : String = "issues";
		public static const AUTOPUBLISH : String = "auto_publish";
		public static const AUTODEPLOY : String = "deploy_issue";
		
		public static const LOGIN_URL : String = "publish/authenticate";
		public static const MAGS_URL : String = "publish/magazines";
		public static const EDITION_URL : String = "publish/editions";
		public static const ISSUE_URL : String = "publish/issues";
		public static const AUTOPUBLISH_URL : String = "publish/auto_publish";
		public static const AUTODEPLOY_URL : String = "publish/deploy_issue";
		
		public static const REST_CALLS : Array = [
			{ type:LOGIN, method:MG, url: ROOT_URL+ LOGIN_URL}
			,{ type:MAGS, method:MG, url: ROOT_URL+ MAGS_URL}
			,{ type:EDITION, method:MG, url: ROOT_URL+ EDITION_URL}
			,{ type:ISSUE, method:MG, url: ROOT_URL+ ISSUE_URL}
			,{ type:AUTOPUBLISH, method:MG, url: ROOT_URL+ AUTOPUBLISH_URL }
			,{ type:AUTODEPLOY, method:MP, url: ROOT_URL+ AUTODEPLOY_URL }
			];
	}
}