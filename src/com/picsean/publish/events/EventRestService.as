package com.picsean.publish.events
{
	import flash.events.Event;
	
	public class EventRestService extends Event
	{
		public var data : *;
		public var action : String;
		public static const EVENT_REST_RESPONSE : String = "EventRestResponse";
		
		
		public function EventRestService(type:String, data:*, action:String,  bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
			this.action = action;
		}
		
		public override function clone ():Event {
			return new EventRestService(type, this.data, this.action);
		}
	}
}