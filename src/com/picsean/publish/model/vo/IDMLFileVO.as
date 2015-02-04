package com.picsean.publish.model.vo
{
	import com.picsean.publish.utils.Constants;
	import com.picsean.publish.utils.CookieHelper;
	
	import flash.filesystem.File;

	public class IDMLFileVO
	{
		public static const PATH_CONST : String = "/home/Library/"; 
		private var rootPath : String
		
		public var local:String = "";
		public var local_file : File
		public var remote : String = "";
		public var isDirectory:Boolean = false;
		
		public function IDMLFileVO(fObj:Object,root:String)	{
			this.rootPath = root;
			process(fObj);
		}
		
		private function process(obj:Object):void	{
			if( String(obj.file).indexOf(".idml") > -1)	{
				local_file = new File(this.rootPath.replace(PATH_CONST,CookieHelper.getInstance().getWorkspace()) + File.separator + obj.file);
				this.local =  (local_file.url);
				this.remote =  this.rootPath.replace(PATH_CONST,Constants.IDML_ROOT) + File.separator + obj.file;
			}
			else	{
				this.local = this.rootPath.replace(PATH_CONST,CookieHelper.getInstance().getWorkspace()) ;
				isDirectory = true;
			}
		}
		
		public function toString():String	{
			return "{Local} " + this.local + "\n {Remote} "+this.remote
		}
		
		private function sanitize( fileName:String ):String
		{
			var p:RegExp = /[:\/\\\*\?"<>\|%]/g;
			return fileName.replace( p, "" );
		}		
	}
}