package com.picsean.publish.model.vo
{
	import com.adobe.indesign.Line;
	import com.adobe.indesign.Lines;
	import com.adobe.indesign.PageItem;
	import com.adobe.indesign.TextFrame;
	import com.adobe.indesign.Word;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.utils.StringHelper;

	public class TextVO
	{
		public var textItem:TextFrame;
		public var locationObj:Object;
		/////////////////////////////////////////////////
		private static const TEXT:String = 'text';
		private static const BASELINE:String = 'baseline';
		private static const START :String = 'start';
		private static const WORDBOUNDRIES:String = 'wordBoundries';
		private var bounds:BoundVO;
		
		private  static var _model:PublishModel = PublishModel.getInstance();
		
		public function TextVO(itm:TextFrame)
		{
			this.textItem = itm;
			getLocation();
		}
		private function getLocation():void{
			bounds = new BoundVO(this.textItem as PageItem);
			locationObj = bounds.createBound();
		}
		public function getlines(lines:Lines):Object{
			var prop:Object = new Object()
				var num:int =0;
			for(var ind:int=0;ind<lines.length;ind++){
				var content:Object=new Object();
				num ++
				var line:Line=lines.item(ind) as Line;
				if(StringHelper.trim((line.contents as String)," ")=="\r") continue;
				content[TEXT]=(line.contents as String).replace("\r","");
				content[BASELINE]=Math.round(Number(Number(line.baseline)/_model.pageRatio)) as Object;
				content[START]=0;
				var wordBoundries:Array=new Array();
				for(var indTwo:int=0;indTwo<line.words.length;indTwo++){
					var word:com.adobe.indesign.Word=line.words.item(indTwo) as Word;
					if((word.contents as String)=="\r")continue;
					if(indTwo==0){
						content[START]=Math.round(Number(Math.abs(Number(word.horizontalOffset)/_model.pageRatio)));
					}
					wordBoundries.push(Math.round(Number(Math.abs(Number(word.endHorizontalOffset)/_model.pageRatio))));
					//trace(word.contents);	
				}
				content[WORDBOUNDRIES]=wordBoundries;
				prop[num] = content;
				
			}
			return prop
		}
	}
}