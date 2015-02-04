package com.picsean.publish.core
{
	import com.picsean.publish.automation.SimpleRESTClient;
	import com.picsean.publish.events.EventRestService;
	import com.picsean.publish.utils.Constants;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	

	public class RESTServiceController implements IRESTServiceController, IEventDispatcher
	{
		private var simpleRest : SimpleRESTClient;
		private var _dispatcher:EventDispatcher
		
		public function RESTServiceController()	{
			initService();
		}
		
		public function initService():void	{
			_dispatcher = new EventDispatcher();
			simpleRest = new SimpleRESTClient();
			simpleRest.addEventListener(EventRestService.EVENT_REST_RESPONSE,eventHandler);
		}
		
		public function doLogin(user_name:String, password:String):void {
			//simpleRest.invokeRest(Constants.LOGIN, {"user_name":user_name, "password":password})
			simpleRest.invokeRest(Constants.LOGIN, "/user_name/"+user_name+"/password/"+password)
		}
		
		public function getMagazines(pubid : String):void	{
			simpleRest.invokeRest(Constants.MAGS, "/pid/"+pubid);
		}
		public function getEditions(pubid:String, magid:String):void	{
			simpleRest.invokeRest(Constants.EDITION, "/pid/"+pubid+"/magid/"+magid)
		}
		public function getIssues(pubid:String, magid:String, editionid:String):void	{
			simpleRest.invokeRest(Constants.ISSUE, "/pid/"+pubid+"/magid/"+magid+"/eid/"+editionid)
		}
		public function autoPublish(pubid:String, magid:String, editionid:String, apath:String):void	{
			simpleRest.invokeRest(Constants.AUTOPUBLISH, "/pid/"+pubid+"/magid/"+magid+"/eid/"+editionid+"/apath/"+apath)
		}
		public function autoDeploy(pubid:String, magid:String, editionid:String, devices:String):void	{
			var param : Object = {"pid":pubid,"magid":magid,"eid":editionid,"devices":devices}; //{"pid":'115',"magid":'1',"eid":'16',"devices":',_iphone,_iphone5,_retina'};//
			simpleRest.invokeRest(Constants.AUTODEPLOY, param)
		}
		
		
		private function eventHandler(event:EventRestService):void	{
			this.dispatchEvent(event);
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