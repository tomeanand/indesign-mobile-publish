package com.picsean.publish.events
{
	import flash.events.Event;
	
	public class EventS3Bucket extends Event
	{
		public static const EVENT_ASSETS_SEARCH_COMPLETED : String = "AssetsSearchCompleted";
		public static const EVENT_DROPPED_INTO_BUCKET : String = "DroppedIntoBucket";
		
		public static const EVENT_JSON_UPLOAD_COMPLETED : String = "JsonUploadComplted";
		
		public var data : *;
		
		public function EventS3Bucket(type:String, data:*, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		public override function clone():Event	{
			return new EventS3Bucket(this.type, this.data, true, false);
		}
	}
}