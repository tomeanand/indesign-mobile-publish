package com.picsean.publish.core
{
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.model.vo.DirectoryVO;
	import com.picsean.publish.model.vo.FileVO;
	import com.picsean.publish.model.vo.PageVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	import org.osmf.logging.Log;
	
	public class PublishQueue extends EventDispatcher
	{
		private var _model : PublishModel = PublishModel.getInstance();
		private var queueCount : Number = 0;
		private var initializeManager : InitializationManager;
		private var directories : LinkedMapFx;
		private var dvo:DirectoryVO;
		private var fvo:FileVO;
		private var keyIndex : Array;
		private var articleFile : File;
		private var articleNumber : Number = 0;
		
		
		public function PublishQueue(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		
		public function initialiseQueue(initMgr:InitializationManager):void	{
			this.initializeManager = initMgr;
			directories = _model.directoryList;
			keyIndex = directories.keysToArray();
			
			
			taskQueue();
			
		}
		
		private function taskQueue():void	{
			
			if(directories.hasKey(keyIndex[queueCount]))	{
				dvo = directories.itemFor(keyIndex[queueCount]);
				
				if(!dvo.tobePublish)	{
					Log.getLogger(Configuration.PICSAEN_LOG).info("found unchanged   "+dvo.getArticleInfoPrint() +"  "+dvo.getTimeInfo());
					//Log.getLogger(Configuration.PICSAEN_LOG).info(dvo.getTimeInfo()+"\n")
					this.dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_FVO_QUEUE_JUMPED,''));
						/**
						 * Adding file reference for ipad rescaling images
						 * Instead of checking the ipad json comparing it with ipad-retina
						 * */
						if(_model.deviceSelected == Configuration.DEVICE_IPAD)	{
							_model.excludedDirectories.add(dvo.getFileId(),dvo);
						}
					return;
				}
				
				
				
				
				articleFile = new File(dvo.getArticleFileName());
				
				fvo = new FileVO(queueCount,articleFile,dvo.type,articleNumber);
				dvo.fileVO = fvo;
				
				if(dvo.type == "p" )	{articleNumber++;}
				
				if(fvo.pageList.size > 1)	{
					printQueue(fvo);
				}
				
				
				
				else	{
					initializeManager.addPublish(new PublishAction(fvo.pageList.first));
					initializeManager.executePublish()
				}
			}
			else	{
				queueCount = 0;
				articleNumber = 0;
				this.dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_QUEUE_COMPLETED,''));
			}
			
		}
		
		private function printQueue(fvo : FileVO):void	{
			var pagelist:LinkedMapFx = fvo.pageList;
			var iterator : IIterator = pagelist.keyIterator();
			var key:String;
			var pgVo:PageVO ;
			
			while (iterator.hasNext()) {
			key = iterator.next();
			pgVo =  pagelist.itemFor(key) as PageVO;
				initializeManager.addPublish(new PublishAction(pgVo));
			} 
				initializeManager.executePublish();
		}
		
		public function restartPublish():void	{
			initializeManager.initialisePublish()
			if(dvo.fileVO)	{	dvo.fileVO.closeDocument();	}
			queueCount ++;
			taskQueue();
		}
		public function jumpQueue():void	{
			initializeManager.initialisePublish()
			queueCount ++;
			taskQueue();			
		}
		
		private function allPublishComplete(event:Event):void	{
			trace("ALL COMPLETED")
		}
	}
}