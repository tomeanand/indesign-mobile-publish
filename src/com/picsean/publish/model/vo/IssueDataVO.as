package com.picsean.publish.model.vo
{
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.utils.Configuration;

	public class IssueDataVO
	{
		public var issuesList : Array
		public var issueJson : String;
		
		public function IssueDataVO(list : Array)
		{
			this.issuesList = list;
			issueJson = JSON.encode(this.issuesList);
		}
		
		public function getDeviceFolders(issuePath:String):Array	{
			var list:Array = new Array();
			var dstring:String = "";
			for(var i:Number = 0; i<this.issuesList.length; i++)	{
				dstring = this.issuesList[i].path
				dstring = dstring.replace(issuePath,"");
				//dstring = dstring.substr(1)
				dstring != Configuration.SPECIAL_PRINT ? list.push({d:dstring,f:this.issuesList[i].path}) : "";
			}
			return list;
		}
	}
}