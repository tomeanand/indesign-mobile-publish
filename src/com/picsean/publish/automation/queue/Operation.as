package com.picsean.publish.automation.queue
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.events.PropertyChangeEvent;

	/**
	 * Dispatched when the execution of an operation has been canceled.
	 */
	[Event(name="canceled", type="operations.OperationEvent")]
	
	/**
	 * Dispatched when the operation has been reset.
	 */
	[Event(name="reset", type="operations.OperationEvent")]
	
	/**
	 * Dispatched after the execution of an operation has started.
	 */
	[Event(name="afterExecute", type="operations.OperationEvent")]
	
	/**
	 * Dispatched before the execution of an operation is about to start.
	 */
	[Event(name="beforeExecute", type="operations.OperationEvent")]
	
	/**
	 * Dispatched when the operation has progressed during its execution.
	 */
	[Event(name="progress", type="operations.ProgressOperationEvent")]
	
	/**
	 * Dispatched when either an error or fault has occurred during the execution
	 * of an operation.
	 */
	[Event(name="fault", type="operations.FaultOperationEvent")]
	
	/**
	 * Dispatched when the execution of an operation has finished. Clients can check
	 * if an operation finished successfully by accessing the events 
	 * <code>successful</code> property.
	 */
	[Event(name="finished", type="operations.FinishedOperationEvent")]
	
	/**
	 * Dispatched a result was received during the execution of an operation. This event
	 * contains the parsed result data.
	 */
	[Event(name="result", type="operations.ResultOperationEvent")]
	
	/**
	 * The <code>Operation</code> is a base class representing an arbitrary atomic request.
	 * Requests can include a simple function call to a class, or more complex operations
	 * that require a network call.
	 * 
	 * @author Dan Schultz
	 */
	public class Operation extends EventDispatcher
	{
		private static const READY:int = 0;
		private static const EXECUTING:int = 1;
		private static const FINISHED:int = 2;
		
		private var _state:int = READY;

		private var _timeoutTimer:Timer;

		private var _retries:Retries = new Retries(0);
		private var _retryTimer:Timer;

		/**
		 * Constructor.
		 */
		public function Operation()
		{
			super();

			_timeoutTimer = new Timer(0, 1);
			_timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimeoutTimer);

			_retryTimer = new Timer(0, 1);
			_retryTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleRetryTimer);
		}
		
		/**
		 * Cancels the request, if it's executing.
		 */
		final public function cancel():void
		{
			if (isExecuting) {
				cancelRequest();
				fireCanceled();
				finish(false);
			}
		}
		
		/**
		 * Performs the actual cancelling of the request. This method is intended
		 * to be overridden by sub-classes and should not be called directly.
		 */
		protected function cancelRequest():void
		{
			
		}
		
		private function changeState(newState:int):void
		{
			_state = newState;
			//dispatchEvent(new Event("propertyChange"));
			dispatchEvent(new mx.events.PropertyChangeEvent("propertyChange"));
		}
		
		/**
		 * Executes the request.
		 */
		final public function execute():void
		{
			if (isReady) {
				changeState(EXECUTING);
				fireBeforeExecute();
				
				if (isExecuting) {
					executeOperation();
					fireAfterExecute();
				}
			}
		}

		private function executeOperation():void
		{
			_timeoutTimer.delay = timeout;
			if (_timeoutTimer.delay > 0) {
				_timeoutTimer.start();
			}

			performOperation();
		}
		
		/**
		 * Performs the execution for this type of operation. This method is intended
		 * to be overridden by sub-classes and should not be called directly.
		 */
		protected function performOperation():void
		{

		}
		
		/**
		 * Called by sub-classes to indicate that an error or fault occurred during 
		 * the execution of the operation. Calling this method will mark the operation
		 * as finished.
		 * 
		 * @param fault The error object.
		 */
		public function fault(fault:Object):void
		{
			if (isExecuting) {
				if (_retries.canRetry) {
					retry();
				} else {
					_error = fault;
					_hasErrored = true;
					fireFault(_error);
					finish(false);
				}
			}
		}
		
		/**
		 * Called by sub-classes to indicate that this operation is finished. This 
		 * method is automatically called when clients invoke either the <code>fault()</code>
		 * or <code>result()</code> methods, but may need to be invoked by sub-classes
		 * in specific cases which do not use these two methods. Do not call this method
		 * after invoking <code>result()</code> or <code>fault()</code>.
		 * 
		 * @param successful <code>true</code> if the operation is successful.
		 */
		final protected function finish(successful:Boolean):void
		{
			if (isExecuting) {
				resetTimers();
				changeState(FINISHED);
				progressed(unitsTotal);
				fireFinished(successful);
			}
		}
		
		private function fireCanceled():void
		{
			if (hasEventListener(OperationEvent.CANCELED)) {
				dispatchEvent( new OperationEvent(OperationEvent.CANCELED) );
			}
		}
		
		private function fireAfterExecute():void
		{
			if (hasEventListener(OperationEvent.AFTER_EXECUTE)) {
				dispatchEvent( new OperationEvent(OperationEvent.AFTER_EXECUTE) );
			}
		}
		
		private function fireBeforeExecute():void
		{
			if (hasEventListener(OperationEvent.BEFORE_EXECUTE)) {
				dispatchEvent( new OperationEvent(OperationEvent.BEFORE_EXECUTE) );
			}
		}
		
		private function fireProgress():void
		{
			if (hasEventListener(ProgressOperationEvent.PROGRESS)) {
				dispatchEvent( new ProgressOperationEvent(ProgressOperationEvent.PROGRESS) );
			}
		}
		
		private function fireFault(fault:Object):void
		{
			if (hasEventListener(FaultOperationEvent.FAULT)) {
				dispatchEvent( new FaultOperationEvent(fault) );
			}
		}

		private function fireReset():void
		{
			if (hasEventListener(OperationEvent.RESET)) {
				dispatchEvent( new OperationEvent(OperationEvent.RESET) );
			}
		}
		
		private function fireResult(data:Object):void
		{
			if (hasEventListener(ResultOperationEvent.RESULT)) {
				dispatchEvent( new ResultOperationEvent(data) );
			}
		}
		
		private function fireFinished(successful:Boolean):void
		{
			if (hasEventListener(FinishedOperationEvent.FINISHED)) {
				dispatchEvent( new FinishedOperationEvent(successful) );
			}
		}

		private function handleRetryTimer(event:TimerEvent):void
		{
			executeOperation();
		}

		private function handleTimeoutTimer(event:TimerEvent):void
		{
			fault("Operation timed out after " + timeout.toString() + "ms.");
		}
		
		/**
		 * Called by sub-classes to indicate the progress of the operation.
		 * 
		 * @param unitsComplete The number of units completed.
		 */
		protected function progressed(unitsComplete:Number):void
		{
			progress.complete = unitsComplete;
			fireProgress();
		}
		
		/**
		 * Resets the operation to its ready state. If the operation is executing, it will be
		 * canceled. If the operation has finished its errors, result data, and progress will
		 * be reset.
		 */
		public function reset():void
		{
			if (isExecuting) {
				resetTimers();
				cancelRequest();
			}
			
			progress.complete = 0;
			_error = null;
			_hasErrored = false;
			_resultData = null;
			
			if (!isReady) {
				changeState(READY);
				fireReset();
			}
		}

		private function resetTimers():void
		{
			_retryTimer.reset();
			_timeoutTimer.reset();
		}

		/**
		 * Called by a sub-class to indicate that a result was received during the
		 * execution of the operation.
		 *
		 * <p>
		 * Calling this method will mark the operation as finished.
		 * </p>
		 *
		 * @param data The result data.
		 */
		protected function result(data:Object):void
		{
			if (isExecuting) {
				_resultData = data;
				fireResult(_resultData);
				finish(true);
			}
		}

		/**
		 * Sets the number of retries for this operation. This method will return a
		 * <code>Retries</code> object where you can change the amount of time between
		 * each retry.
		 *
		 * <p>
		 * <strong>Example:</strong> Setting the retry attempts and their delays for a network
		 * operation:
		 *
		 * <listing version="3.0">
		 * operation.retries(3).withDelay(1500, 3000, 6000);
		 * </listing>
		 * </p>
		 *
		 * @param count The number of retries to attempt before failing.
		 * @return A retry object to set the delay intervals.
		 */
		public function retries(count:uint):Retries
		{
			if (isExecuting) {
				throw new Error("Cannot change retries while operation is executing.");
			}
			_retries = new Retries(count);
			return _retries;
		}

		private function retry():void
		{
			_retryTimer.delay = _retries.reattempt();
			_retryTimer.start();
		}

		private var _error:Object;
		[Bindable(event="fault")]
		/**
		 * The fault object if the operation errored out.
		 */
		public function get error():Object
		{
			return _error;
		}
		
		[Bindable(event="propertyChange")]
		/**
		 * Indicates whether the request is currently executing.
		 */
		final public function get isExecuting():Boolean
		{
			return _state == EXECUTING;
		}
		
		[Bindable(event="propertyChange")]
		/**
		 * Indicates whether the request is finished, either successfully or unsuccessfully.
		 */
		final public function get isFinished():Boolean
		{
			return _state == FINISHED;
		}
		
		[Bindable(event="propertyChange")]
		/**
		 * Indicates whether the request is idle and ready to be executed.
		 */
		final public function get isReady():Boolean
		{
			return _state == READY;
		}
		
		[Bindable(event="propertyChange")]
		/**
		 * Indicates whether the request has finished, and hasn't errored.
		 */
		final public function get isSuccessful():Boolean
		{
			return isFinished && !hasErrored;
		}

		private var _hasErrored:Boolean;
		[Bindable(event="propertyChange")]
		/**
		 * <code>true</code> if this operation errored during its execution.
		 */
		final public function get hasErrored():Boolean
		{
			return _hasErrored;
		}
		
		private var _progress:Progress;
		[Bindable(event="progress")]
		/**
		 * Information about the progress of this operation.
		 */
		public function get progress():Progress
		{
			if (_progress == null) {
				_progress = new Progress();
				_progress.total = unitsTotal;
			}
			return _progress;
		}

		private var _resultData:Object;
		[Bindable(event="result")]
		/**
		 * The operation's result data.
		 */
		public function get resultData():Object
		{
			return _resultData;
		}

		private var _timeout:Number = 0;
		/**
		 * The number of milliseconds with each attempt before this operation will timeout.
		 */
		public function get timeout():Number
		{
			return _timeout;
		}
		public function set timeout(value:Number):void
		{
			_timeout = isNaN(value) ? 0 : value;
		}
		
		/**
		 * The number of units needed to complete this operation.
		 */
		protected function get unitsTotal():Number
		{
			return 1;
		}
	}
}