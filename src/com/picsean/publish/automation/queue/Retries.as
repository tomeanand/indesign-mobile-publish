package com.picsean.publish.automation.queue
{
	public class Retries
	{
		private var _attempt:uint;
		private var _retryCount:uint;
		private var _delays:Array;

		public function Retries(retryCount:uint)
		{
			_retryCount = retryCount;
			_delays = [];
		}

		internal function reattempt():Number
		{
			if (canRetry) {
				_attempt++;
				return _delays.length == 0 ? 0 : _delays[Math.min(_delays.length-1, _attempt-1)];
			}
			return NaN;
		}

		public function withDelay(...delays):Retries
		{
			_delays = delays.length > _retryCount ? delays.slice(0, _retryCount) : delays;
			return this;
		}

		public function get canRetry():Boolean
		{
			return _attempt < _retryCount;
		}
	}
}
