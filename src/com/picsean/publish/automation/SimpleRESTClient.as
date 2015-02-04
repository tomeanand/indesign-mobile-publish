package com.picsean.publish.automation
{
	import com.adobe.net.URI;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.events.EventRestService;
	import com.picsean.publish.utils.Constants;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.as3commons.collections.fx.LinkedMapFx;
	import org.httpclient.HttpClient;
	import org.httpclient.HttpRequest;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpListener;
	import org.httpclient.events.HttpResponseEvent;
	import org.httpclient.http.Post;
	
	public class SimpleRESTClient implements IEventDispatcher
	{
		private var httpClient:HttpClient;
		private var listener : HttpListener;
		private var callInfo : Object;
		private var parameters : Object;
		private var invokeList : LinkedMapFx;
		private var requestUri : URI;
		private var _dispatcher:EventDispatcher
		
		private var urlLoader:URLLoader;
		private var contentType:String = "application/json";
		private var json : String = "";
		private var jsonData : ByteArray;
		
		
		public function SimpleRESTClient()
		{
			_dispatcher = new EventDispatcher();
			initialise()
		}
		
		private function initialise():void	{
			httpClient = new HttpClient();
			
			listener = new HttpListener();
			listener.onComplete = onCompleteData;
			listener.onData = onDataReceived;
			httpClient.listener = listener;
			
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE,onLoadComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			
			
			invokeList = new LinkedMapFx();
			for(var i:Number = 0; i<Constants.REST_CALLS.length; i++)	{
				invokeList.add(Constants.REST_CALLS[i].type, Constants.REST_CALLS[i])
			}
			
			
		}
		private function onLoadComplete(event:Event):void	{
			//trace(event.target.data)
			dispatchEvent(new EventRestService(EventRestService.EVENT_REST_RESPONSE, JSON.decode(String(event.target.data)),callInfo.type,true ));
		}
		
		private function onIOError(event:IOErrorEvent):void	{
			trace(event.text);
		}
		private function onDataReceived(event:HttpDataEvent):void	{
			var data:String = event.readUTFBytes();
			dispatchEvent(new EventRestService(EventRestService.EVENT_REST_RESPONSE, JSON.decode(data),callInfo.type,true ));
		}
		private function onCompleteData(event:HttpResponseEvent):void	{
			//trace(event)
		}
		public function invokeRest(type:String,params:Object):void	{
			callInfo = invokeList.itemFor(type);
			this.parameters = params;
			
			if(callInfo.method == Constants.MP)	{
				requestUri = new URI(callInfo.url);
				
				json = JSON.encode(params);
				jsonData = new ByteArray();
				jsonData.writeUTFBytes(json);
				jsonData.position = 0;
				
				httpClient.post(requestUri, jsonData, contentType);
				
			}
			else if(callInfo.method == Constants.MG)	{
				urlLoader.load( new URLRequest(callInfo.url + params));
				/*requestUri = new URI(callInfo.url + params);
				httpClient.get(requestUri,listener);*/
			}
			else	{
				//do nothing
			}
		}
		
		
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public function dispatchEvent(event:Event):Boolean {
			return _dispatcher.dispatchEvent(event);
		}
		public function hasEventListener(type:String):Boolean {
			return _dispatcher.hasEventListener(type);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		public function willTrigger(type:String):Boolean {
			return _dispatcher.willTrigger(type);
		}		
		
	}
}