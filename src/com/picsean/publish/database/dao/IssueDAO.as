package com.picsean.publish.database.dao
{
	import com.picsean.publish.model.vo.IssueRawVO;
	
	import mx.collections.ArrayCollection;

	public class IssueDAO extends BaseDAO
	{
		public static const TABLE_NAME : String = "s3_issues_master";
		
		public function IssueDAO()
		{
			super();
		}
		
		public function create(issuevo:IssueRawVO):IssueRawVO {
			var id:int = createItem(
				"INSERT INTO "+TABLE_NAME+" (pubid,magid,editionid,magazine_name,publisher_name,issue_folder,issue_data) " +
				"VALUES (?,?,?,?,?,?,?)",
				[	issuevo.pubid,
					issuevo.magid,
					issuevo.editionid,
					issuevo.magazineName,
					issuevo.publisherName,
					issuevo.issueFolder,
					issuevo.issuesDataVO.issueJson
				]);
			issuevo.id = id;
			
			return issuevo;
		}
		
		public function update(issuevo:IssueRawVO):IssueRawVO {
			executeUpdate(
				"UPDATE "+TABLE_NAME+" SET issue_data = ? WHERE id=?",
				[	issuevo.issuesDataVO.issueJson,
					issuevo.id
				]);
			
			return issuevo;
		}
		
		public function remove(issuevo:IssueRawVO):void	{
			executeUpdate("DELETE FROM "+TABLE_NAME+" WHERE  id=? ", [ issuevo.id]);
		}
		
		
		public function exists(pubid:String, magid:String, editionid:String):Boolean	{
			var issuevo:IssueRawVO = getIssue(pubid,magid,editionid);
			var isExist:Boolean = false;
			if(issuevo.editionid != null){
				isExist =  true;
			}
			
			return isExist;
		}
		
		public function getIssue(pubid:String, magid:String, editionid:String):IssueRawVO	{ 
			var fakeVo : IssueRawVO =  new IssueRawVO(null);
			fakeVo.id = 0;
			var res:ArrayCollection = getList("SELECT * FROM "+TABLE_NAME+" WHERE pubid=? AND magid=? AND editionid=? ", [pubid,magid,editionid]);
			
			if(res == null || res.length <= 0) return fakeVo; 
			
			return res.getItemAt(0) as IssueRawVO;
		}	
		
		
		
		override protected function processRow(row:Object):Object	{
			var issuevo : IssueRawVO = new IssueRawVO();
			issuevo.processDbRow(row);
			return issuevo;
		}
		
	}
}