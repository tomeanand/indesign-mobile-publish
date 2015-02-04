package com.picsean.publish.model.vo
{
	import com.adobe.indesign.AnchorPoint;
	import com.adobe.indesign.CoordinateSpaces;
	import com.adobe.indesign.Document;
	import com.adobe.indesign.Page;
	import com.adobe.indesign.ResizeMethods;
	import com.adobe.indesign.SaveOptions;
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	import com.picsean.publish.model.LayoutVO;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import org.as3commons.collections.fx.LinkedMapFx;
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	
	
	public class FileVO
	{
		public var pageList:LinkedMapFx = new LinkedMapFx();
		public var id:int;
		public var url:String;
		public var file:File;
		public var orientation:String;
		
		private var _page:Page;
		private var _document:Document;
		private var _model:PublishModel = PublishModel.getInstance();
		private var articleNumber :int;
		
		private var logInfo : String = "";
		private var artilceNum:int = 0;
		private var pageNum:int = 0;
		
		private var idCount:int = 0;
		private var timer:Timer = new Timer(2000);
		private var articleSerialNumber :  Number = 0;
		
		
		public function FileVO(id:Number,file:File,orient:String,anum:int = 0) {
			this.file = file;
			this.id = id;
			this.url = file.url;
			this.orientation = orient;
			this.articleNumber = anum;
			createPageList();
			
		}
		
		private function createPageList():void	{
			var pgUrl:String;
			var fileUrl:String;
			var layoutVO:LayoutVO;
			var pgVO:PageVO;
			
			//EventTransporter.getInstance().addEventListener(EventFilePublish.EVENT_PAGE_PUBLISH, onPagePublishHandler);
			//timer.addEventListener(TimerEvent.TIMER , activateTimer);
			//idCount  =0;
			_document = _model.app.open(this.file.nativePath,false) as Document;
			var pgLength:Number = _document.pages.length;
			 // hack to remove the CSSDK log
			
			var slNo:Number = Number( String( this.url.substring(this.url.lastIndexOf(File.separator)+1).split(".")[0]).substring(1));
			
			if(this.orientation == "p")	{
				logInfo = (int(slNo)+"|Article|"+_document.pages.length +"\n");
				EventTransporter.getInstance().dispatchEvent(new EventFilePublish(
					EventFilePublish.EVENT_ARTILCE_INFO_WRITE,
					{pages:_document.pages.length,article:int(slNo)}));
			}
			
			
			//this.orientation == "p" ?  (logInfo = int(this.articleNumber)+"|Article|"+"1" +"\n") : '';
			pageNum = 0;
			for(var i:int; i<pgLength; i++){
				_page = _document.pages.item(i) as Page;
				_page.label = "pg_"+i;
				//pgUrl = File( _document.filePath ).url + File.separator + pageKey(i+1); // pageKey is for making pages unique, otherwise Urls will be same across "File( _document.filePath ).url"
				pgUrl = (this.url.substring(0,this.url.lastIndexOf(File.separator))) + File.separator + pageKey(i+1); // pageKey is for making pages unique, otherwise Urls will be same across "File( _document.filePath ).url"
				/**
				 * Resize the page for iPad - non Retina
				 * */
				layoutVO = getLayout(_page);
				//resizePage(layoutVO,_page)
				//_model.pageList.add(pgUrl,new PageVO(_page,i,pgUrl,this.orientation,layoutVO));
				pgVO = new PageVO(_page,i,pgUrl,this.orientation,layoutVO);
				if(i == pgLength-1)	{
					pgVO.isLastPage = true;
				}
				pageList.add(pgUrl,pgVO);
				pageNum++;
			}	
			
			//getPageList();
			
			
		}
		
		
		private function getPageList():void{
			var layoutVO:LayoutVO;
			var pgUrl:String;
			var fileUrl:String;
			
			_page = _document.pages.item(idCount) as Page;
			_page.label = "pg_"+idCount;
			fileUrl = File( _document.filePath ).url;
			pgUrl = fileUrl + File.separator + pageKey(idCount+1);
			layoutVO = getLayout(_page);
			var pageVo:PageVO = new PageVO(_page,idCount,pgUrl,this.orientation,layoutVO) 
			pageVo.documentPath = fileUrl;
			_model.pageList.add(pgUrl,pageVo);

			pageNum++;
			
			//logInfo = int(this.id)-1+"|Article|"+pageNum +"\n";
			
			pageVo.invokeHandler();
		}
		
		public function getPublishLog():String	{
			if(_model.replativePanoPO.length>0){
				for( var i :Number =0 ;i< _model.replativePanoPO.length ;i++){
					var article:String = _model.replativePanoPO.getItemAt(i).name;
					article = article.substring(0,article.lastIndexOf("/"));
					var filenum:String = article.substring(article.lastIndexOf("/")+1);
					if( this.file.url == (article+File.separator+filenum +Configuration.INDD)){
						logInfo = int(this.articleNumber)+"|Article|1 \n";
					}
				}
			}
			return logInfo;
		}
		
		public function closeDocument():void	{ 
			
			//trace("CLOSING   "+this.file.url.toString());
			try	{
				//_document.close();
				_document.close(SaveOptions.NO,null,null,false);
				Log.getLogger(Configuration.PICSAEN_LOG).info("CLOSING   ...."+this.file.url.substring(this.file.url.length-20)+"\n");
			}
			catch(e:Error)	{
				trace("Error in closing file ------->  "+e.message)
			}	
		}
		
		private function resizePage(layout:LayoutVO, page:Page):void	{
			/*if(layout.device != Configuration.DEVICE_IPAD)	{
				return
			}
			page.resize(CoordinateSpaces.INNER_COORDINATES, AnchorPoint.CENTER_ANCHOR,
				ResizeMethods.REPLACING_CURRENT_DIMENSIONS_WITH, [layout.width, layout.height]);*/
		}
		
		private function onPagePublishHandler(event:EventFilePublish):void{
			//Log.getLogger(Configuration.PICSAEN_LOG).info("onPagePublishHandler___________________________   "+event.data.pagenum);
			if( idCount < _document.pages.length -1 ){
				idCount ++;
				timer.start()
			}else{
				if( timer.running ){ timer.stop(); }
				//PageVO(_model.pageList.last()).isLastPage = true;
				var pageVo:PageVO = _model.pageList.last as PageVO;
				pageVo.isLastPage = true;
				
			
				EventTransporter.getInstance().removeEventListener(EventFilePublish.EVENT_PAGE_PUBLISH, onPagePublishHandler);
				EventTransporter.getInstance().dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_FILE_PUBLISH,this));
			}
		}
		
		private function activateTimer(event:TimerEvent):void{
			timer.stop();
			getPageList()
		}
		
		private function pageKey(num:Number):String	{
			return (num < 10 ?  "p0"+num.toString() : "p"+num.toString());
		}
		public function toString():String	{
			return this.url;
		}
		private function getLayout(page:Page):LayoutVO	{
			var layout:LayoutVO;
			
			var pgWidth:Number = page.bounds[3] - page.bounds[1] as Number;
			var pgHeight:Number = page.bounds[2] - page.bounds[0] as Number;
			var pageDimension : Point = new Point(pgWidth, pgHeight);
			
			if(this.orientation == 'l')	{
				return new LayoutVO(this.orientation,_model.pageHeight,_model.pageWidth,_model.pageRatio, pageDimension, _model.directoryPath, _model.deviceSelected);
			}
			else	{
				return new LayoutVO(this.orientation,_model.pageWidth,_model.pageHeight,_model.pageRatio, pageDimension, _model.directoryPath, _model.deviceSelected);
			}
		}
	}	
}