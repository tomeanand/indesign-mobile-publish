package com.picsean.publish.upload
{
	import com.adobe.net.URI;
	import com.picsean.publish.events.EventS3Bucket;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpClient;
	import org.httpclient.events.HttpResponseEvent;
	import org.httpclient.http.multipart.Multipart;
	import org.httpclient.http.multipart.Part;
	
	public class RESTFileUpload extends EventDispatcher
	{
		
		private var client:HttpClient;
		private var bucketName:String = "xxx.xxx.xx.xxx";//"burberry.picsean.com anand.picsean.com";
		private var uri:URI; 
		private var accessKey:String = "xxx";  
		private var secretAccessKey:String = "xxx";
		
		
		public function RESTFileUpload(target:IEventDispatcher=null)
		{
			super(target);
			
			client = new HttpClient();
			uri = new URI("http://" + bucketName + ".s3.amazonaws.com/");
			client.listener.onComplete = onCompleteData;
			
		}
		
		public function uploadToS3(item:Object):void	{
			var postOptions:S3PostOptions = new S3PostOptions(bucketName, item.key, accessKey, { contentType: item.ctype, acl:'public-read' });      
			var policy:String = postOptions.getPolicy();
			
			var signature:String = postOptions.getSignature(secretAccessKey, policy);
			//trace("signature=" + signature);
			//trace("policy=" + policy);
			
			var data:ByteArray = item.payload as ByteArray; new ByteArray();
			data.position = 0;
			
			var multipart:Multipart = new Multipart([ 
				new Part("key", item.key), 
				new Part("Content-Type", item.ctype),
				new Part("acl", 'public-read'),
				new Part("AWSAccessKeyId", accessKey),
				new Part("Policy", policy),
				new Part("Signature", signature),
				new Part("file", data, item.ctype, [ { name:"filename", value:item.f } ]),
				new Part("submit", "Upload")
			]);
			
			client.postMultipart(uri, multipart);
		}
		
		
		private function onCompleteData(event:HttpResponseEvent):void	{
			this.dispatchEvent(new EventS3Bucket(EventS3Bucket.EVENT_DROPPED_INTO_BUCKET,''));
		}		
	}
}