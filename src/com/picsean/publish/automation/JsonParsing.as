package com.picsean.publish.automation
{
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Timer;
	import flash.utils.flash_proxy;
	
	import mx.collections.ArrayCollection;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;

	public class JsonParsing
	{
		private var _jsonlist:ArrayCollection;
		private var file:File;
		private var mergables : LinkedMapFx;
		
		private var counter : Number = 0;
		private var pgCounter : Number = 0;
		
		private var artilceTimer : Timer = new Timer(2000);
		private var pageTimer : Timer = new Timer(2000);
		
		private var artilces:ArrayCollection;
		
		
        private const PAGE_COUNT: int= 150; 		
		public function JsonParsing()
		{
			
		}
		
		public function init(list:ArrayCollection):void	{
			mergables = new LinkedMapFx();
			
			for(var i:Number= 0; i<list.length; i++)	{
				
				mergables.add("page_"+i.toString(), readFiles(list[i].path));
			}
			
			//artilceTimer.addEventListener(TimerEvent.TIMER, articleTimerHandler);
			pageTimer.addEventListener(TimerEvent.TIMER, pageTimerHandler);
			
			
			initateMerge()
			
		}
		
		private function initateMerge():void	{
			pgCounter = 0;
			artilces = mergables.itemFor("page_"+counter) as ArrayCollection;
			streamJson(artilces.getItemAt(pgCounter).f)		
		}
		
//		private function articleTimerHandler(event:TimerEvent) :void	{
//			if(counter < mergables.size-1)	{
//				artilceTimer.stop();
//				pgCounter = 0;
//				counter ++;
//				initateMerge()
//			}
//			else	{
//				if(artilceTimer.running)	{artilceTimer.stop();}
//				if(pageTimer.running)	{pageTimer.stop();}
//				getJsonData()
//			}
//			
//		}
		
		private function pageTimerHandler(event:TimerEvent) :void	{
			if(pgCounter < artilces.length - 1)	{
				pgCounter ++;
				pageTimer.stop();
				streamJson(artilces.getItemAt(pgCounter).f);
				
			}
			else	{
				pgCounter = 0;
				counter ++;
				if(counter > mergables.size -1)	{
					if(pageTimer.running){pageTimer.stop()};
					getJsonData();
				}else{
				initateMerge()
				streamJson(artilces.getItemAt(pgCounter).f)	}
			}
		}
		
		
		private function streamJson(path:String):void	{
			trace(artilces.getItemAt(pgCounter) +"        "+pgCounter+"   >>>>>>>>>>>    "+path)
			var f:File = new File(path)
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.READ);
			var feedJson:String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			var pobject:Object = JSON.decode(feedJson);
			artilces.getItemAt(pgCounter).json = pobject;
			
			pageTimer.start();
			
		}
		
		private function getJsonData():void{
			var jsonObject :Object ;
			
			var subfeature01 :Array = new Array();
			var subfeature02:Array = new Array();
			
			var pages:ArrayCollection;
			var iterator : IIterator = mergables.keyIterator();
			
			while (iterator.hasNext()) {
				
				pages = mergables.itemFor(iterator.next()) as ArrayCollection;
				var topPage : Object = pages.getItemAt(0).json;
				for(var i:Number=1; i<pages.length; i++)	{
					
					pages.getItemAt(0).json[0].subfeatures[0].images.push( pages.getItemAt(i).json[0].subfeatures[0].image  )
					pages.getItemAt(0).json[0].subfeatures[1].images.push( pages.getItemAt(i).json[0].subfeatures[1].image  )
						try{
							if(pages.getItemAt(0).json[0].subfeatures[1].subfeatures[0].type == Configuration.TYPE_SLIDESHOW || Configuration.TYPE_JUMP || Configuration.TYPE_VIDEO_FEATURE || Configuration.TYPE_VIDEOTRIGGER){
								subfeature02.push(pages.getItemAt(0).json[0].subfeatures[1].subfeatures[0]);}
						}
						catch(e:Error){
							
						}
						
					delete pages.getItemAt(0).json[0].subfeatures[0].image;
					delete pages.getItemAt(0).json[0].subfeatures[1].image;
					var sub:Array =pages.getItemAt(i).json[0].subfeatures[0].subfeatures;
					var sub1:Array =pages.getItemAt(i).json[0].subfeatures[1].subfeatures;
					
					if( sub.length >0){
								subfeature01.push(pages.getItemAt(i).json[0].subfeatures[0].subfeatures[0])
								//pages.getItemAt(0).json[0].subfeatures[0].subfeatures.push(pages.getItemAt(i).json[0].subfeatures[0].subfeatures)
					}
					if( sub1.length >0){
						for( var j:int=0;j<sub1.length; j++){
								subfeature02.push(pages.getItemAt(i).json[0].subfeatures[1].subfeatures[j])};
								//pages.getItemAt(0).json[0].subfeatures[1].subfeatures.push( pages.getItemAt(i).json[0].subfeatures[1].subfeatures)
						
					}
					/*pages.getItemAt(0).json[0].subfeatures[0].subfeatures = subfeature01;
					pages.getItemAt(0).json[0].subfeatures[1].subfeatures = subfeature02;
*/					
					/*var test = topPage[0].subfeatures[0].images;
					var test1 = topPage['0'].subfeatures[0].images;
					var test0 = topPage[0].subfeatures['0'].images;
					var test01 = topPage['0'].subfeatures['0'].images;*/
				}
				if(subfeature01.length>0){
				pages.getItemAt(0).json[0].subfeatures[0].subfeatures = subfeature01;}
				if(subfeature02.length>0){
				pages.getItemAt(0).json[0].subfeatures[1].subfeatures = subfeature02;}
				/*pages.getItemAt(0).json[0].subfeatures[0] = subfeature01;
				pages.getItemAt(0).json[0].subfeatures[1] = subfeature02;*/

				trace(JSON.encode( pages.getItemAt(0).json) )
				writeJson(pages.getItemAt(0))
				trace ("domne");
				subfeature01  = new Array();
				subfeature02 = new Array();
				deleteJsonFiles();
				
			}
			
			//
			//PublishModel.getInstance().replativePanoPO = new ArrayCollection();
			PublishModel.getInstance().relativePanoArticleList = mergables;
			EventTransporter.getInstance().dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_JSON_MERGE_COMPLETE,this));
			
			
			
		}
		
		
		private function writeJson(json:Object):void{
			var jsonFile : File= new File(json.f);
			var stream : FileStream = new FileStream();
			stream.open(jsonFile,flash.filesystem.FileMode.WRITE);
			stream.writeUTFBytes(JSON.encode(json.json));
			stream.close();
			
		}
		
		private function readFiles(filePath:String):ArrayCollection	{
			var newfile:String = filePath.substring(0,filePath.lastIndexOf("/"));
			
			
			var filelist :ArrayCollection = new ArrayCollection();
			filelist.addItem({f:filePath+".json", json:null});
			
			for(var i:int = 2; i<PAGE_COUNT; i++)	{
				var fileName : String = getFileName(i, newfile);
				
				file = new File(fileName);
				if(file.exists)	{
					filelist.addItem({f:file.url, json:null});
				}
				else	{
					break;
				}
			}
			return filelist;
		}
		
		
		private function getFileName(num:Number, path:String):String	{
			if(num<10)	{
				return path+"/p0"+num+".json";
			}
			return path+"/p"+num+".json";
		}
		
		
		private function deleteJsonFiles():void{
			var pages:ArrayCollection;
			var iterator : IIterator = mergables.keyIterator();
			while (iterator.hasNext()) {
				pages = mergables.itemFor(iterator.next()) as ArrayCollection;
				for(var i:Number=1; i<pages.length; i++)	{
					var file:File =new File(pages[i].f);
					if(file.exists){
						file.deleteFile();}
				}
				}
		}
		
	}
}

//file:///Users/anup_picsean/Documents/test/3_demos/1_publishing/233_luxos2014/p/a00/p01