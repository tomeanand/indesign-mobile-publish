package com.picsean.publish.core
{
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	
	public class InitializationAction extends EventDispatcher
	{
		public static const DIRECTORY : String = "DIRECTORY";
		public static const FILE : String = "FILE";
		public static const PAGE : String = "PAGE";
		
		public var actionType:String;
		protected var logger:Logger;
		
		public function InitializationAction(target:IEventDispatcher=null)
		{
			super(target);
			createLogger();
		}
		
		public function execute():void{
			
		}
		
		protected function createLogger():void	{
			logger = Log.getLogger(Configuration.PICSAEN_LOG);
		}
	}
}