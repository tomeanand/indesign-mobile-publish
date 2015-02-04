package com.picsean.publish.core
{
	import com.adobe.indesign.Document;
	import com.adobe.indesign.SaveOptions;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.model.vo.FileVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.logging.Log;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	
	public class CompletionManager extends EventDispatcher
	{
		private var _model:PublishModel = PublishModel.getInstance();
		
		public function CompletionManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function completeExecution():void	{
			var iterator : IIterator = _model.openDocList.keyIterator();
			var key : String;
			var openedDoc : Document
			
			while(iterator.hasNext())	{
				key = iterator.next();
				openedDoc = _model.openDocList.itemFor(key) as Document;
				openedDoc.close(SaveOptions.NO);
				Log.getLogger(Configuration.PICSAEN_LOG).info("{0} : Document closed",key);
				_model.openDocList.remove(key);
			}
			_model.openDocList = new LinkedMapFx();
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public static function removeDocument(fvo:FileVO):void	{
			try	{
				//fvo.closeDocument();
			}catch(e:Error)	{
				Log.getLogger(Configuration.PICSAEN_LOG).info("Document not closed")
			}
		}
		
	}
	

}