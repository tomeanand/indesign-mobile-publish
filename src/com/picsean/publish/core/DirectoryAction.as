package com.picsean.publish.core
{
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.model.vo.DirectoryVO;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	public class DirectoryAction extends InitializationAction
	{
		
		public function DirectoryAction(target:IEventDispatcher=null)
		{
			super(target);
			this.actionType = InitializationAction.DIRECTORY;
		}
		override public function execute():void{
			getDirectoryList();
			dispatchEvent(new Event(Event.COMPLETE));
			
		}
		
		private function getDirectoryList():void{
			var issueDirFile:File = new File(PublishModel.getInstance().publishVO.directory);
			var subDir:Array = issueDirFile.getDirectoryListing();
			for (var i:int=0; i<subDir.length; i++){
				var item:File = subDir[i] as File;
				if (item.name == "l" && item.isDirectory){
					getSubDirList(item,'l');
				}else if (item.name == "p" && item.isDirectory){
					getSubDirList(item,'p');
				}
			}
		}
		
		private function getSubDirList(dir:File,orient:String):void{
			var subDir:Array = dir.getDirectoryListing();
			for (var i:Number=0; i<subDir.length; i++){
				var item:File = subDir[i] as File;
				if(item.isDirectory){
				var dvo :DirectoryVO = new DirectoryVO(item.url,orient,i,PublishModel.getInstance().publishVO.device);
				var artfilename:File =new File( dvo.getArticleFileName() )
					if(artfilename.exists){
					 	PublishModel.getInstance().directoryList.add(orient+i.toString(),dvo);
					}
				}
			}
		}
	}
}