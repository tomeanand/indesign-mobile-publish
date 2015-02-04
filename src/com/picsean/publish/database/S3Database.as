package com.picsean.publish.database
{
	import com.picsean.publish.utils.Configuration;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLStatement;
	import flash.data.SQLTransactionLockType;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	
	import org.osmf.logging.Log;

	public class S3Database
	{
		
		public static const SQLSTMT_CRT_TABLE_S3_DATAPUSH : String = "CREATE TABLE IF NOT EXISTS s3_bucketmaster_info ("+
			"id INTEGER PRIMARY KEY AUTOINCREMENT, name varchar(250), url varchar(550), status INTEGER, last_pushed DATE )"

		public static const SQLSTMT_CRT_TABLE_ISSUES_MASTER : String = 'CREATE TABLE IF NOT EXISTS "s3_issues_master" ('+
			'"id" INTEGER PRIMARY KEY AUTOINCREMENT, "pubid" varchar(5), "magid" varchar(5), "editionid" varchar(5), "magazine_name" varchar(40), "publisher_name" varchar(40), "issue_folder" varchar(200), "issue_data" TEXT )';
		
		private var SQL_STMT_LIST : Array;
		private var isDBCreated : Boolean = true;
			
		public function S3Database()	{
		}
		
		
		public function initDatabase():void	{
			var _databaseFile:File = File.documentsDirectory.resolvePath("publishplus.db");
			isDBCreated = true;
			
			SQL_STMT_LIST = [SQLSTMT_CRT_TABLE_S3_DATAPUSH, SQLSTMT_CRT_TABLE_ISSUES_MASTER];
			
			try {
				if(!_databaseFile.exists) {
					isDBCreated = false;
					Log.getLogger(Configuration.PICSAEN_LOG).info("DB Not Created");
				}
				
				var sqlConnection:SQLConnection = new SQLConnection();
				sqlConnection.open(_databaseFile, SQLMode.CREATE, false, 1024);
				SQLConnectionManager.setConnection(SQLConnectionManager.CON_NAME, sqlConnection);
				Log.getLogger(Configuration.PICSAEN_LOG).info("DB Connected");
				
				if(!isDBCreated) {
					createTables();
				}
			}
			catch (error:SQLError) {
				throw error;
			}
			
		}
		
		private function createTables():void	{
			var connection:SQLConnection = SQLConnectionManager.getConnection(SQLConnectionManager.CON_NAME);
			connection.begin(SQLTransactionLockType.IMMEDIATE);	
			for(var i:Number = 0; i<SQL_STMT_LIST.length; i++)	{
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = connection;
				stmt.text = SQL_STMT_LIST[i];
				stmt.execute();	
				Log.getLogger(Configuration.PICSAEN_LOG).info("Table created "+ SQL_STMT_LIST[i]);
			}
				
			connection.commit();
			isDBCreated = true;
		}
		
		public function runInitQueries():void	{
			Log.getLogger(Configuration.PICSAEN_LOG).info("runInitQueries");
			if(!isDBCreated) {
				createTables();
			}
		}
		
	}
}