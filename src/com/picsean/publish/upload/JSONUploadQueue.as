package com.picsean.publish.upload
{
	import com.picsean.publish.automation.queue.FinishedOperationEvent;
	import com.picsean.publish.automation.queue.OperationQueue;
	import com.picsean.publish.automation.queue.OperationQueueEvent;
	import com.picsean.publish.events.EventS3Bucket;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	import org.osmf.logging.Log;
	
	public class JSONUploadQueue extends EventDispatcher
	{
		private var operationObj : Object;
		private var queueCount : Number = 0;
		
		public function JSONUploadQueue(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function initOperation(jsonList : LinkedMapFx):void	{
			
			var opQueue : OperationQueue = new OperationQueue(1);
			opQueue.addEventListener(OperationQueueEvent.PROGRESS,onQueueProgress);		
			
			var iterator : IIterator = jsonList.keyIterator();
			var uploadOp : JSONUploadOperation;
			var key : String;
			
			while(iterator.hasNext())	{
				key = iterator.next();
				
				operationObj = {file:jsonList.itemFor(key), key:key};
				
				uploadOp = new JSONUploadOperation(operationObj);
				uploadOp.addEventListener("finished",onOperationFinished);
				uploadOp.addEventListener("result",onOperationResult);
					
				opQueue.queue( uploadOp );
			}
			
			opQueue.start();			
		}
		private function onOperationResult(event:Object):void	{
			var result:Object = event.data as Object;

			Log.getLogger(Configuration.PICSAEN_LOG).info("Uploade into Server  ::: "+result.info);
			
			if(queueCount <= 0)	{
				completeTask()
			}
			
			
		}
		private function onQueueProgress(event:OperationQueueEvent):void	{
			queueCount  = event.queue.queued.length;
		}
		private function onOperationFinished(event:FinishedOperationEvent):void	{
			
		}
		private function completeTask():void	{
			Log.getLogger(Configuration.PICSAEN_LOG).info("******************** Upload JSON Completed***********");
			this.dispatchEvent(new EventS3Bucket(EventS3Bucket.EVENT_JSON_UPLOAD_COMPLETED,"done"));
		}
		
	}
}