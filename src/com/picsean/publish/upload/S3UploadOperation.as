package com.picsean.publish.upload
{
	import com.picsean.publish.automation.queue.FinishedOperationEvent;
	import com.picsean.publish.automation.queue.OperationQueue;
	import com.picsean.publish.automation.queue.OperationQueueEvent;
	import com.picsean.publish.database.dao.PushFileDao;
	import com.picsean.publish.model.vo.PushFileVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	import org.osmf.logging.Log;
	
	public class S3UploadOperation extends EventDispatcher
	{
		private var dao:PushFileDao;
		private var pfvo : PushFileVO;
		private var operationObj : Object;
		private var transactionType : Object;
		private var queueCount : Number = 0;
		
		private static const TYPE_INSERT : String = "INSERT";
		private static const TYPE_UPDATE : String = "UPDATE";
		
		public function S3UploadOperation(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function initOperation(uplodList:LinkedMapFx):void	{
			
			dao = new PushFileDao();
			
			var opQueue : OperationQueue = new OperationQueue(2);
			opQueue.addEventListener(OperationQueueEvent.PROGRESS,onQueueProgress);		
			
			var iterator : IIterator = uplodList.keyIterator();
			var uploadOp : ImageS3UploadOperation;
			var key : String;
			
			while(iterator.hasNext())	{
				key = iterator.next();
				
				operationObj = {file:uplodList.itemFor(key), key:key};
				transactionType = getTransactionType(operationObj);
				operationObj.transaction = transactionType;
					
				if( transactionType.isQueued )	{
					uploadOp = new ImageS3UploadOperation(operationObj);
					uploadOp.addEventListener("finished",onOperationFinished);
					uploadOp.addEventListener("result",onOperationResult);
						
					opQueue.queue( uploadOp );
				}
			}
			
			opQueue.start();
		}
		
		private function onQueueProgress(event:OperationQueueEvent):void	{
			queueCount  = event.queue.queued.length;
		}
		
		private function onOperationResult(event:Object):void	{
			var result:Object = event.data as Object;
			var file:File = result.file as File;
			
			if( result.transaction.type == TYPE_INSERT)	{
				pfvo = new PushFileVO(result.key,file.url,1,file.modificationDate);
				dao.create(pfvo);
			}
			else if(result.transaction.type == TYPE_UPDATE)	{
				pfvo = result.transaction.vo as PushFileVO;
				dao.update(pfvo);
			}
			else	{
				// do nothing
			}
			Log.getLogger(Configuration.PICSAEN_LOG).info("Db "+result.transaction.type+" and dropped into S3  ::: "+result.key);
			
			if(queueCount <= 0)	{
				completeTask()
			}
			
			
		}
		private function getTransactionType(data:Object):Object	{
			
			pfvo = dao.getFile(data.key);
			if(pfvo.id == 0)	{
				transactionType = {isQueued : true, type:TYPE_INSERT};
				return transactionType;
			}
			
			var file:File = operationObj.file as File;
			
			var dbtime :Date = pfvo.last_pushed;
			var filetime : Date = file.modificationDate;
			trace(dbtime+":::::"+filetime+"---->   "+(filetime.getTime() - dbtime.getTime() ) )
			
			if(filetime.getTime() - dbtime.getTime() > 2000)	{
				transactionType = {isQueued : true, type:TYPE_UPDATE, vo:pfvo};
			}
			else	{
				transactionType = {isQueued : false, type:""};
			}
			
			return transactionType;
		}
		private function onOperationFinished(event:FinishedOperationEvent):void	{
			
		}
		private function completeTask():void	{
			Log.getLogger(Configuration.PICSAEN_LOG).info("******************** Completed S3 upload ***********")
		}
	}
}