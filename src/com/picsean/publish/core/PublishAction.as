package com.picsean.publish.core
{
	import com.adobe.indesign.Document;
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.ExportRangeOrAllPages;
	import com.adobe.indesign.Spread;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	import com.picsean.publish.feature.ConvertedPanoramaFeature;
	import com.picsean.publish.feature.IFeature;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.model.vo.PageVO;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	
	public class PublishAction extends InitializationAction
	{
		private var pageVO:PageVO;
		private var _model:PublishModel = PublishModel.getInstance();
		
		private var doc:Document; 
		private var exportFile:File;
		private var url:String;
		private var format:ExportFormat
		
		public function PublishAction(pvo:PageVO)
		{
			this.pageVO = pvo;
		}
		
		public override function execute():void	{
			
			_model.app.jpegExportPreferences.jpegExportRange = ExportRangeOrAllPages.EXPORT_RANGE;
			_model.app.jpegExportPreferences.exportResolution=72;
			
			//pushlishFeatures();
			publishMainPage();
		
		}
		
		private function publishMainPage():void	{
			
			var f_list:LinkedMapFx = pageVO.featureList;
			var iterator:IIterator = f_list.keyIterator();
			var fname:String;
			var feature:IFeature;
			var json_array:Array = new Array();
			while (iterator.hasNext()) {
				fname = iterator.next();
				feature = f_list.itemFor(fname) as IFeature;
				json_array.push(feature.getJSON());
			}
			this.writeJson(JSON.encode(json_array));
			
			

			
			
			
			
			
			
			
			
			
			
			var doc:Document, exportFile:File,thumbFile:File, url:String;
			doc = (pageVO.page.parent as Spread).parent;
			exportFile = new File(pageVO.filePath + ".jpg");
			thumbFile = new File(pageVO.filePath + "_t.jpg");
			
			pageVO.enableDrawFeatures(false);

			

			format = ExportFormat.jpg;
			 
			_model.app.jpegExportPreferences.pageString = pageVO.page.name;
			
			doc.exportFile(format, exportFile, false);
			
			
			_model.app.jpegExportPreferences.jpegExportRange = ExportRangeOrAllPages.EXPORT_RANGE;
			_model.app.jpegExportPreferences.exportResolution=23.76;
			doc.exportFile(format, thumbFile, false);
			_model.app.jpegExportPreferences.jpegExportRange = ExportRangeOrAllPages.EXPORT_RANGE;
			_model.app.jpegExportPreferences.exportResolution=72;
			
			
			
			//logger.info("\n\n  Published file pano:{0} and file:{1} \n\n",pageVO.isPano,pageVO.fileName);
			pageVO.enableDrawFeatures(true);
			// convertedpano has been missing its page index 
			// so the panorama printing is having a mismatch in the page and its always printing the last page
			// in this method the reference is page is coming proper, that being the reason printing 
			// the coververted pano feature from this method. 
			// :: Reason :: Ever since the execute is called in iterative from InitialisationManager
			//				the context of the print page is missing, (index, currentpage etc)
			//				yet to be ironed out the root cause
			if(pageVO.isPano && pageVO.featureList.first is ConvertedPanoramaFeature)	{
				var cpano : ConvertedPanoramaFeature = pageVO.featureList.first as ConvertedPanoramaFeature;
				cpano.printPano();
			}
			
			// THE ABOVE enableDrawFeatures METHOD WILL ADD IF ANY CORRUPTED FILES ARE PRESENT
			if(this.pageVO.isCorrupted)	{
				_model.corruptedFileList.push(this.pageVO.fileName);
			}
			
			if(pageVO.isLastPage)	{
				this.dispatchEvent( new EventFilePublish(EventFilePublish.EVENT_FVO_DONE,this.pageVO));
			}
			else	{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function pushlishFeatures():void	{
			var f_list:LinkedMapFx = pageVO.featureList;
			var iterator:IIterator = f_list.keyIterator();
			var fname:String;
			var feature:IFeature;
			var json_array:Array = new Array();
			while (iterator.hasNext()) {
				fname = iterator.next();
				feature = f_list.itemFor(fname) as IFeature;
				json_array.push(feature.getJSON());
			}
			this.writeJson(JSON.encode(json_array))
			//trace("  Published  Images  "+pageVO.fileName)
		}
		private function writeJson(json:String):void{
			var jsonFile : File= new File(pageVO.filePath + ".json");
			var stream : FileStream = new FileStream();
			stream.open(jsonFile,flash.filesystem.FileMode.WRITE);
			stream.writeUTFBytes(json);
			stream.close();
		}
	}
}