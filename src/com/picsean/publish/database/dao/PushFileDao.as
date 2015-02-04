package com.picsean.publish.database.dao
{
	import com.picsean.publish.model.vo.PushFileVO;
	
	import mx.collections.ArrayCollection;

	public class PushFileDao extends BaseDAO
	{
		public static const TABLE_NAME : String = "s3_bucketmaster_info";
		public function PushFileDao()
		{
			super();
		}
		public function create(pushFile:PushFileVO):PushFileVO {
			var id:int = createItem(
				"INSERT INTO "+TABLE_NAME+" (name,url,status,last_pushed) " +
				"VALUES (?,?,?,?)",
				[	pushFile.name,
					pushFile.url,
					pushFile.status,
					pushFile.last_pushed
				]);
			pushFile.id = id;
			
			return pushFile;
		}
		
		public function update(pushFile:PushFileVO):PushFileVO {
			executeUpdate(
				"UPDATE "+TABLE_NAME+" SET name = ?, url = ?, status = ?, last_pushed=? WHERE id=?",
				[	pushFile.name,
					pushFile.url,
					pushFile.status,
					pushFile.last_pushed,
					pushFile.id
				]);
			
			return pushFile;
		}
		
		public function remove(pfvo:PushFileVO):void	{
			executeUpdate("DELETE FROM "+TABLE_NAME+" WHERE name=? AND id=? ", [pfvo.name, pfvo.id]);
		}
		
		public function exists(name:String):Boolean	{
			var pfvo:PushFileVO = getFile(name);
			
			if(pfvo != null || pfvo.name == "") return false;
			
			return true;
		}
		
		public function getFile(key : String):PushFileVO	{ 
			var fakeVo : PushFileVO =  new PushFileVO("","",0,null);
			fakeVo.id = 0;
			var res:ArrayCollection = getList("SELECT * FROM "+TABLE_NAME+" WHERE name=? ", [key]);
			
			if(res == null || res.length <= 0) return fakeVo; 
			
			return res.getItemAt(0) as PushFileVO;
		}		
		
		override protected function processRow(row:Object):Object	{
			var pfvo : PushFileVO = new PushFileVO(
									row.name, row.url, row.status, row.last_pushed);
			pfvo.id = row.id;
			return pfvo;
		}
	}
}