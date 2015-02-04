package com.picsean.publish.core
{
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.model.vo.DirectoryVO;
	import com.picsean.publish.model.vo.PageVO;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	
	public class PageAction extends InitializationAction
	{
		private var _model:PublishModel = PublishModel.getInstance();
		
		public function PageAction(target:IEventDispatcher=null)
		{
			super(target);
			this.actionType = InitializationAction.PAGE;
		}
		
		override public function execute():void{
			//getPages();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function getPages():void{
			var pagelist:LinkedMapFx = _model.pageList;
			var iterator : IIterator = pagelist.keyIterator();
			var pgVo:PageVO ;
			while (iterator.hasNext()) {
				pgVo =  pagelist.itemFor(iterator.next());
				//trace("--------> "+pgVo.layout.toString())
				//pgVo.populate();
			}
		}
	}
}