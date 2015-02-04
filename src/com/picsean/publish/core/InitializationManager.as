package com.picsean.publish.core
{
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;

	public class InitializationManager extends EventDispatcher
	{
		
		private var _actionsArray:Array;
		private var _publishArray:Array;
		private var _actionCount:Number = 0;
		private var _publishCount:Number = 0;
		
		
		public function InitializationManager()
		{
		}
		
		public function setupActions():void	{
			_actionsArray = new Array();
			_publishArray = new Array();
			_actionCount  = 0;
			_publishCount = 0;			
		}
		
		public function addActions(action:InitializationAction):void{
			_actionsArray.push(action);
		}
		public function addPublish(action:PublishAction):void{
			_publishArray.push(action);
		}
		
		public function executeAction():void{
			var action:InitializationAction;
			for(var i:int =0; i< _actionsArray.length;i++){
				action = _actionsArray[i] as InitializationAction;
				action.addEventListener(Event.COMPLETE,completehandler);
			}
			InitializationAction(_actionsArray[_actionCount]).execute();
		}

		public function initialisePublish():void	{
			_publishArray = new Array();
			_publishCount = 0;				
		}
		public function executePublish():void{
			var action:PublishAction;
			for(var i:int =0; i< _publishArray.length;i++){
				action = _publishArray[i] as PublishAction;
				action.addEventListener(Event.COMPLETE,publishEventHandler);
				action.addEventListener(EventFilePublish.EVENT_FVO_DONE,eventFVODone);
				
			}
			PublishAction(_publishArray[_publishCount]).execute();
		}
		
		private function  eventFVODone(event:EventFilePublish):void	{
			this.dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_FVO_COMPLETED,''));
		}
		
		private function completehandler(event:Event):void{
			Log.getLogger(Configuration.PICSAEN_LOG).info(event.target.actionType);
			switch(InitializationAction(event.target).actionType)	{
				case InitializationAction.DIRECTORY: 
					//_actionCount++;
					//InitializationAction(_actionsArray[_actionCount]).execute();
					this.dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_DIRECTORY_DONE, ''));
				break;
				case InitializationAction.FILE :
					_actionCount++;
					/** 
					 * as of now no process is happening in page action
					 * found some issue in processing it there, so bypassing PageAction and triggering complete event from here
					 * Uncomment / commect the below lines if you need to process anything on PageAction
					 * */
					//InitializationAction(_actionsArray[_actionCount]).execute();
					dispatchEvent(new Event(Event.COMPLETE));
				break;
				case InitializationAction.PAGE :
					dispatchEvent(new Event(Event.COMPLETE));
				break;
			}
		}
		
		private function publishEventHandler(event:Event):void{
			if(_publishCount < _publishArray.length-1)	{
				_publishCount++;
				PublishAction(_publishArray[_publishCount]).execute();
			}
			else	{
				dispatchEvent(new Event(Event.CLOSE));
			}
		}

	}
}