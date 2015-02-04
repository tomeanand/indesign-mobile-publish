package com.picsean.publish.download
{
	import com.picsean.publish.automation.queue.Operation;
	import com.picsean.publish.model.vo.IDMLFileVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import org.osmf.logging.Log;
	
	public class IDMLDownload extends Operation
	{
		private var fileStream : FileStream;
		private var stream:URLStream;
		
		private var idml:IDMLFileVO;
		
		
		public function IDMLDownload(idml:IDMLFileVO)
		{
			super();
			
			initialiseOperation(idml);
		}
		
		private function initialiseOperation(idml:IDMLFileVO):void	{
			this.idml = idml;
			
			stream =  new URLStream();
			fileStream = new FileStream();
			stream.addEventListener(ProgressEvent.PROGRESS, progressBar);
			stream.addEventListener(Event.COMPLETE, writeComplete);
			
			
		}
		private function writeComplete(evt:Event):void	{
			
			var fileData:ByteArray = new ByteArray();
			stream.readBytes(fileData,0,stream.bytesAvailable);
			
			fileStream.openAsync(idml.local_file, FileMode.UPDATE)
			fileStream.writeBytes(fileData,0,fileData.length);
			fileStream.close();
			
			stream.removeEventListener(ProgressEvent.PROGRESS, progressBar);
			stream.removeEventListener(Event.COMPLETE, writeComplete);
			
			result( {result:'success', file:this.idml } );
		}
		private function progressBar(event:ProgressEvent):void	{
			
		}

		
		override protected function performOperation():void	{
			Log.getLogger(Configuration.PICSAEN_LOG).debug("------>  "+this.idml.remote);
			stream.load(new URLRequest(this.idml.remote));
		}
		
		private function cancelHandler(event:Event):void 
		{
			fault({result:'oops'});	
		}
		
		
		private function handleLoaderError(event:IOErrorEvent):void 
		{
			result( {result:'ioerror',data : event} );
		
		}
	}
}