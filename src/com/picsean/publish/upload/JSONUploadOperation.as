package com.picsean.publish.upload
{
	import com.adobe.net.URI;
	import com.picsean.publish.automation.queue.Operation;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpClient;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpResponseEvent;
	import org.httpclient.http.multipart.Multipart;
	import org.httpclient.http.multipart.Part;
	
	public class JSONUploadOperation extends Operation
	{
		private var _loader : URLLoader;
		private var operationObj:Object;
		private var file:File
		private var contentType : String = "";
		private var uploadPath :String = "";
		private var client : HttpClient;
		
		//private static const UPLOAD_URL : String = "http://localhost/analytics_dashboard/index.php/api/publish/upload";
		private static const UPLOAD_URL : String = "http://www.picsean.com/testdashboard/api/publish/upload";
		private static const TYPE_JSON :String = "json";
		private static const CNT_TYPE_JSON :String = "application/json";
		private static const CNT_TYPE_TXT :String = "text/plain";
		
		
		public function JSONUploadOperation(opObj:Object)
		{
			super();
			
			this.operationObj = opObj;
			file = opObj.file as File;
			this.uploadPath = getUploadPath();
			
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, handleLoaderComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
		}
		
		override protected function performOperation():void	{
			_loader.load(new URLRequest(file.url));
		}
		
		private function uploadJSON(json:String):void	{
			client = new HttpClient();
			var uri:URI = new URI(UPLOAD_URL);
			
			client.listener.onData = function(event:HttpDataEvent):void {
				// Notified with response content in event.bytes as it streams in
			};
			
			client.listener.onComplete = function(event:HttpResponseEvent):void {
				
				operationObj.info = "json_uploaded";
				result( operationObj );
			};
			
			
			if(file.extension == TYPE_JSON)	{
				contentType = CNT_TYPE_JSON;
			}
			else	{
				contentType = CNT_TYPE_TXT;
			}
			
			
			var jsonData:ByteArray = new ByteArray();
			jsonData.writeUTFBytes(json);
			jsonData.position = 0;
			
			var multipart:Multipart = new Multipart([ 
				new Part("upath", this.uploadPath), 
				new Part("Content-Type", contentType),
				new Part("file", jsonData, contentType, [ { name:"filename", value:file.name } ]),
				new Part("submit", "Upload")
			]);
			
			client.postMultipart(uri, multipart);
		}
		
		private function handleLoaderComplete(event:Event):void	{
			uploadJSON(_loader.data);
		}
		
		private function handleLoaderError(event:IOErrorEvent):void	{
			operationObj.info = "json_failed";
			fault(operationObj);			
		}
		private function getUploadPath():String	{
			var path:String = this.operationObj.key;
			path = path.substring(0,path.lastIndexOf(File.separator)+1);
			path = "/home/Library/"+path;
			return path;
		}
	}
}