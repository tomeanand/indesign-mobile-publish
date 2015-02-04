package com.picsean.publish.events
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class EventTransporter extends EventDispatcher
	{
		private static var _instance : EventTransporter;
		
		
		public static function getInstance():EventTransporter	{
			if(!_instance)	{
				_instance = new EventTransporter();
			}
			return _instance;
		}
		public function EventTransporter(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}