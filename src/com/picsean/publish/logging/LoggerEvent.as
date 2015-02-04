package com.picsean.publish.logging
{
	import flash.events.Event;
	
	public class LoggerEvent extends Event
	{
		public static const LOGGER_EVENT : String = "LOGGER_EVENT";
		public var message:String;
		
		public function LoggerEvent(type:String, message:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.message = message;
		}
	}
}