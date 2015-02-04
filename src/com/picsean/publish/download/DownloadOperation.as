package com.picsean.publish.download
{
	import com.picsean.publish.automation.queue.OperationQueue;
	import com.picsean.publish.automation.queue.OperationQueueEvent;
	import com.picsean.publish.database.dao.IssueDAO;
	import com.picsean.publish.model.vo.IDMLFileVO;
	import com.picsean.publish.model.vo.IssueRawVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	import org.as3commons.collections.LinkedMap;
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	import org.osmf.logging.Log;
	
	public class DownloadOperation extends EventDispatcher
	{
		private var dao : IssueDAO;
		private var isuvo : IssueRawVO;
		private var db_isuvo : IssueRawVO;
		private var downloadList : LinkedMapFx;
		
		private var queueCount : Number = 0;
		
		public function DownloadOperation(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function initOperation(ivo:IssueRawVO):void	{
			downloadList = new LinkedMapFx();
			
			isuvo = ivo;
			dao = new IssueDAO();
			if(!dao.exists( ivo.pubid,ivo.magid,ivo.editionid ))	{
				dao.create( ivo );
				downloadList = getDownloadList(ivo);
				Log.getLogger(Configuration.PICSAEN_LOG).info("!dao.exists");
				Log.getLogger(Configuration.PICSAEN_LOG).debug(downloadList.size.toString());
			}
			else	{
				db_isuvo = dao.getIssue( ivo.pubid,ivo.magid,ivo.editionid );
				downloadList = getComparedList(db_isuvo, isuvo);
				Log.getLogger(Configuration.PICSAEN_LOG).info("dao.exists");
				Log.getLogger(Configuration.PICSAEN_LOG).debug(downloadList.size.toString());
			}
			Log.getLogger(Configuration.PICSAEN_LOG).debug(downloadList.size.toString());
			if(downloadList.size > 0 )	{
			
				var iterator:IIterator = downloadList.keyIterator();
				var key:String;
				var item : IDMLFileVO;
				
				var opQueue : OperationQueue = new OperationQueue(2);
				opQueue.addEventListener(OperationQueueEvent.PROGRESS,onQueueProgress);	
				var idmldownload:IDMLDownload;
				
				while(iterator.hasNext())	{
					key = iterator.next();
					item = downloadList.itemFor(key) as IDMLFileVO;
					if(!item.isDirectory)	{
						Log.getLogger(Configuration.PICSAEN_LOG).info("key - >" + item.toString());
						idmldownload = new IDMLDownload(item);
						idmldownload.addEventListener("result",onOperationResult);
						
						opQueue.queue( idmldownload );
					}
					else	{
						Log.getLogger(Configuration.PICSAEN_LOG).info("key - >" + item.local);
						createDirectory(item);
					}
				}
				opQueue.start();
				
			}
			
		}
		
		protected function getDownloadList(issueVO:IssueRawVO):LinkedMapFx	{
			var list:LinkedMapFx = new LinkedMapFx();
			var dlist : Array = issueVO.issuesDataVO.issuesList;
			var device : Object, o_path :Object, f_idml:Object;
			var path : String, key:String;
			var dataObj:Object;
			var idmlVO:IDMLFileVO;
			
			for(var i:Number = 0; i<dlist.length; i++)	{
				device = dlist[i].directory as Object;
				path = dlist[i].path;
				for(var orient:String in device)	{
					o_path = device[orient];
					for(var idml:String in o_path)	{
						f_idml = o_path[idml];
						key = path+"/"+orient+"/"+idml;
						dataObj = ( f_idml.length != 0 ? f_idml[0] : {'file':idml});
						idmlVO = new IDMLFileVO(dataObj,key);
						list.add(key,idmlVO);
					}
				}
			}
			return list;
		}
		
		protected function getComparedList(db:IssueRawVO, current:IssueRawVO):LinkedMapFx	{
			return this.getDownloadList(db);
		}
		private function onOperationResult(event:Object):void	{
			var result:Object = event.data as Object;
			Log.getLogger(Configuration.PICSAEN_LOG).info("Downloaded  "+result.file.local);
			
			if(queueCount <= 0)	{
				Log.getLogger(Configuration.PICSAEN_LOG).info("******************** Completed all downloads ***********");
			}
		}
		private function onQueueProgress(event:OperationQueueEvent):void	{
			queueCount  = event.queue.queued.length;
		}
		
		private function createDirectory(idml:IDMLFileVO):void{
			var pageDir : File = new File(idml.local);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		
	}
}