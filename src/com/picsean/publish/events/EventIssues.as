package com.picsean.publish.events
{
	import flash.events.Event;
	
	public class EventIssues extends Event
	{
		public static const EVENT_LOGOUT : String = "logout";
		public static const EVENT_S3_PUSH : String = "s3_push";
		public static const EVENT_PUBLISH_ISSUE : String = "publishIssue";
		public static const EVENT_SET_WORKSPACE : String = "setWorkspace";
		
		public var data : *;
		
		public function EventIssues(type:String, data:*, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		public override function clone():Event	{
			return new EventIssues(this.type, this.data, true, false);
		}
	}
}