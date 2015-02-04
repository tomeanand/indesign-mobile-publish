package com.picsean.publish.events
{
	import flash.events.Event;
	
	public class EventFilePublish extends Event
	{
		public static const EVENT_FILE_PUBLISH : String = "FilePublishEvent";
		public static const EVENT_PAGE_PUBLISH :String = "PagePublishEvent";
		
		public static const EVENT_SCALE_COMPLETED :String = "ScaleComepletedEvent";
		public static const EVENT_SCALE_IMAGES :String  = "ScaleImageEvent";
		
		public static const EVENT_PANO_SLICE :String = "SliceImageEvent";
		public static const EVENT_JSON_MERGE_COMPLETE :String = "JsonMergeComplete";
		
		
		public static const EVENT_CLOSE_FILE_PUBLISH : String = "CloseFilePublish"; 
		
		/**/
		public static const EVENT_DIRECTORY_DONE : String = "DiectoryDone"; 
		public static const EVENT_FVO_DONE : String = "FVODone"; 
		public static const EVENT_FVO_COMPLETED : String = "FVCopmpleted"; 
		public static const EVENT_QUEUE_COMPLETED : String = "QueueComplted"; 
		public static const EVENT_FVO_QUEUE_JUMPED : String = "FVOQueueJumped"; 
		/**
		 * 
		 * */
		public static const EVENT_ARTILCE_INFO_WRITE : String = "EventArticleWrite"; 
		
		public var data : *;
		
		public function EventFilePublish(type:String, data : *, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}