package com.picsean.publish.automation.queue
{
	import flash.events.Event;

	/**
	 * An event dispatched by an operation to indicate that an error or fault
	 * has occurred during its execution.
	 * 
	 * @author Dan Schultz
	 */
	public class FaultOperationEvent extends OperationEvent
	{
		/**
		 * An event type for when an operation has errored or faulted during execution.
		 */
		public static const FAULT:String = "fault";
		
		/**
		 * Constructor.
		 * 
		 * @param fault The object that contains details of the error.
		 */
		public function FaultOperationEvent(fault:Object)
		{
			super(FAULT);
			
			_fault = fault;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new FaultOperationEvent(fault);
		}
		
		private var _fault:Object;
		/**
		 * The details of the fault.
		 */
		public function get fault():Object
		{
			return _fault;
		}
	}
}