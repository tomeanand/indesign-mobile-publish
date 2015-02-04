package com.picsean.publish.model.vo
{
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.database.dao.IssueDAO;
	import com.picsean.publish.utils.CookieHelper;

	public class IssueRawVO
	{
		public var id:Number;
		
		public var pubid : String;
		public var magid : String;
		public var editionid : String;
		public var magazineName : String;
		public var publisherName : String;
		public var issueFolder : String;
		public var issuesDataVO : IssueDataVO;
		public var devices:Array;
		public var local:String;
		
		public function IssueRawVO(raw:Object = null)
		{
			if(raw)	{
				processRaw(raw)
			}
		}
		private function processRaw(raw:Object):void	{
			this.pubid = raw.pubid;
			this.magid = raw.magid;
			this.editionid = raw.edition;
			this.magazineName = raw.magazine_name;
			this.publisherName = raw.publisher.publishername;
			this.issueFolder = raw.issue_folder;
			this.issuesDataVO =  new IssueDataVO(raw.list);
			
			this.local = issueFolder.replace(IDMLFileVO.PATH_CONST,CookieHelper.getInstance().getWorkspace());
			this.devices = this.issuesDataVO.getDeviceFolders(this.issueFolder);
		}
		
		public function processDbRow(obj:Object):void	{
			this.id = obj.id;
			this.pubid = obj.pubid;
			this.magid = obj.magid;
			this.editionid = obj.editionid;
			this.magazineName = obj.magazine_name;
			this.publisherName = obj.publisher_name;
			this.issueFolder = obj.issue_folder;
			this.issuesDataVO =  new IssueDataVO(JSON.decode(obj.issue_data));
			
			this.local = issueFolder.replace(IDMLFileVO.PATH_CONST,CookieHelper.getInstance().getWorkspace());
			this.devices = this.issuesDataVO.getDeviceFolders(this.issueFolder);
		}
		
		
		
		public function toString():String	{
			return "{ PUB ID } "+this.pubid+ " { MAG ID } "+this.magid+ " { EDITION ID } "+this.editionid+ " { NAME } "+this.magazineName+" { FOLDER } "+ this.local;
		}
		
	}
}
