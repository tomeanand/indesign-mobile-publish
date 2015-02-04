package com.picsean.publish.automation
{
	import com.picsean.publish.automation.queue.FinishedOperationEvent;
	import com.picsean.publish.automation.queue.OperationQueue;
	import com.picsean.publish.automation.queue.OperationQueueEvent;
	import com.picsean.publish.automation.queue.ResultOperationEvent;
	import com.picsean.publish.automation.queue.SimpleScaleOperation;
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import org.osmf.logging.Log;
	
	public class ImageScaleOperation extends EventDispatcher
	{
		private var totalCount:Number = 0;
		private var queueCount : Number = 0;
		private var infoMsg : String = "";
		private var _model : PublishModel = PublishModel.getInstance();
		private var _rescaleList : ArrayCollection;
		private var deviceFoler : String = "";
		
		private static const THUMB_LITERAL : String = "_t.jpg";
		
		public function ImageScaleOperation(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function initOperation(data : ArrayCollection):void	{
			_rescaleList = new ArrayCollection();
			totalCount = data.length;
			
			
			var excluded : Array = _model.excludedDirectories.keysToArray();
			var fileName : String = "";
			deviceFoler = _model.iPadFolderPath.substring( _model.iPadFolderPath.lastIndexOf( File.separator )+1);

			/**
			 * Removing items which are not been republished
			 * **/
			
			var found:Boolean = false;
			var i:Number = 0;
			
			for( i = 0; i<totalCount; i++)	{
				fileName = data.getItemAt(i).path;
				found = false;
				for(var j:Number = 0; j<excluded.length; j++)	{
					if( Number (fileName.indexOf(excluded[j])) > 0  )	{
						found = true;
						break;
					}
				}
				if(!found)	{
					_rescaleList.addItem(data.getItemAt(i))
				}
			}
			
			/*for( i = 0; i<totalCount; i++)	{
				fileName = data.getItemAt(i).path;
				if( tobeScaled(fileName) )	{
					_rescaleList.addItem(data.getItemAt(i));
				}
			}*/
			
	
			
			/**
			 * If items are present for rescaling
			 * adding that into queue or dispatching scale complate
			 * */
			
			if(_rescaleList.length > 0)	{
				
				var scaler:SimpleScaleOperation;
				var opQueue : OperationQueue = new OperationQueue();
				var pathName :String = "";
				
				opQueue.addEventListener(OperationQueueEvent.PROGRESS,onQueueProgress);				
				totalCount = _rescaleList.length;
				
				for(i = 0; i<totalCount; i++)	{
					pathName = _rescaleList.getItemAt(i).path;
					/**
					 * excluding thumbnails from reszing;
					 * */
					//if( pathName.indexOf(THUMB_LITERAL) < 0)	{
						scaler = new SimpleScaleOperation( {path :pathName , count : i } );
						scaler.addEventListener("finished",onOperationFinished);
						scaler.addEventListener("result",onOperationResult);
						opQueue.queue( scaler );
					//}
				}
				
				opQueue.start();
				
			}
			else	{
				completeTask()
			}
			
			
			
		}
		
		private function onOperationResult(event:Object):void	{
			var fname : String = event.data.info
			infoMsg = _model.iPadFolderPath+" Resized : ..."+fname.substring(fname.indexOf(_model.directoryPath));
			//_model.deviceSelected
			Log.getLogger(Configuration.PICSAEN_LOG).info("("+(totalCount-queueCount)+" of "+totalCount+") "   +infoMsg);
			
			var operation:SimpleScaleOperation = event.target as SimpleScaleOperation;
			operation.releaseMemory();
			
			if(queueCount <= 0)	{
				completeTask()
			}
		}
		private function onOperationFinished(event:FinishedOperationEvent):void	{
			//Log.getLogger(Configuration.PICSAEN_LOG).info("Complete "+ event.type)
		}
		private function onQueueProgress(event:OperationQueueEvent):void	{
			queueCount  = event.queue.queued.length;
			
		}
		
		private function completeTask():void	{
			Log.getLogger(Configuration.PICSAEN_LOG).info(" .................RESIZING COMPLETED.............. ");
			EventTransporter.getInstance().dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_SCALE_COMPLETED,this));
		}
		
		
		private function tobeScaled(fname:String):Boolean	{
			var timeDiff:Object = new Object();
			var f_normal:File = new File(fname);
			var rFileName : String = fname.replace(deviceFoler, deviceFoler+Configuration.IPAD_RETINA_LITERAL_PUBLISH);
			var f_retina:File = new File(rFileName);
			var tobe : Boolean = true;
			
			if(f_normal.exists)	{
				timeDiff.retina = f_retina.modificationDate.getTime();
				timeDiff.normal = f_normal.modificationDate.getTime();
				timeDiff.txt = "RETINA  "+f_retina.modificationDate.getTime()+"    NORMAL    "+f_normal.modificationDate.getTime() +":::"+(timeDiff.normal - timeDiff.retina);
				trace(timeDiff.txt)
				tobe = ((timeDiff.retina - timeDiff.normal) > 2000 ? true : false)
			}
			return tobe;
		}		
	}
}