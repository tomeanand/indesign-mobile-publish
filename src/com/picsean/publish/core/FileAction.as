package com.picsean.publish.core
{
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.model.vo.DirectoryVO;
	import com.picsean.publish.model.vo.FileVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	import org.osmf.logging.Log;
	
	public class FileAction extends InitializationAction
	{
		private var _model:PublishModel = PublishModel.getInstance();
		private var articleFile:File;
		
		private var idCount:int;
		private var directories:LinkedMapFx;
		private var articleNumber:int
		
		public function FileAction(target:IEventDispatcher=null)
		{
			super(target);
			this.actionType = InitializationAction.FILE;
		}
		override public function execute():void{
			 directories = _model.directoryList;
			var iterator : IIterator = directories.keyIterator();
			var dvo:DirectoryVO;
			var fvo:FileVO;
			 idCount = 0;
			 articleNumber = 0;
			 EventTransporter.getInstance().addEventListener(EventFilePublish.EVENT_FILE_PUBLISH, onFilePublishHandler);
			
			 addItemToList(idCount);
			/*while (iterator.hasNext()) {
				dvo = directories.itemFor(iterator.next());
				articleFile = new File(dvo.getArticleFileName());
				fvo = new FileVO(idCount,articleFile,dvo.type);
				dvo.fileVO = fvo
				idCount ++;
				_model.openDocList.add(articleFile.url,fvo);
			}
			
			dispatchEvent(new Event(Event.COMPLETE));*/
		}
		
		private function addItemToList(index:Number):void	{
			var dvo:DirectoryVO;
			var fvo:FileVO;
			var keyIndex : Array = directories.keysToArray();
			
			if(directories.hasKey(keyIndex[index]))	{
				dvo = directories.itemFor(keyIndex[index]);
				articleFile = new File(dvo.getArticleFileName());
				
				articleNumber = (dvo.type == "p" ? articleNumber++ : 0);
			
				fvo = new FileVO(idCount,articleFile,dvo.type,articleNumber);
				dvo.fileVO = fvo
				
			}
			else	{
				EventTransporter.getInstance().removeEventListener(EventFilePublish.EVENT_FILE_PUBLISH, onFilePublishHandler);
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		
		private function onFilePublishHandler(event:EventFilePublish):void	{
			//var fvo : FileVO = event.data as FileVO;
			//_model.openDocList.add(articleFile.url,fvo);
			//_model.addOpenDocList(articleFile.url,fvo);
			//idCount ++;
			//Log.getLogger(Configuration.PICSAEN_LOG).info("Article  ->>>>>>       "+fvo.file.name + "   Completed ");
			//addItemToList(idCount);
			
		}
	}
}