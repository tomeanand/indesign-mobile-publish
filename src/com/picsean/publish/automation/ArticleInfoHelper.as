package com.picsean.publish.automation
{
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;

	public class ArticleInfoHelper
	{
		private var loader:URLLoader;
		private var articles:LinkedMapFx;
		private var infoUrl:String;
		
		public function ArticleInfoHelper()
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onFileLoaded);
			EventTransporter.getInstance().addEventListener(EventFilePublish.EVENT_ARTILCE_INFO_WRITE,onArticleInfoData);
		}
		
		public function intialiseInfo(url:String, isLoad:Boolean):void	{
			infoUrl = url;
			articles = new LinkedMapFx();
			if(isLoad)	{
				loader.load( new URLRequest(url));
			}
		}
		
		private function onFileLoaded(event:Event):void	{
			var a_list:Array = event.target.data.split(/\n/);
			var split:Array;
			for(var i:Number = 0; i<a_list.length; i++)	{
				if(a_list[i] != "")	{
					split = String(a_list[i]).split("|");
					articles.add("a_"+split[0], {entry:a_list[i], article:split[0], pages:split[2]});
				}
			}
		}
		
		private function onArticleInfoData(event:EventFilePublish):void	{
			var data:Object = event.data;
			var key : String = "a_"+data.article;
			//while article is not present
			if(!articles.hasKey(key))	{
				articles.add(key,{entry:(data.article+"|Article|"+data.pages), article:data.article, pages:data.pages });
			}
			// article is present and pages differs
			if(articles.hasKey(key))	{
				var pageItem:Object = articles.itemFor(key);
				if(pageItem.pages != data.pages)	{
					pageItem.pages = data.pages;
					pageItem.entry = data.article+"|Article|"+data.pages
					articles.replaceFor(key,pageItem);
				}
			}
			writeArticleInfo();
		}
		
		
		private function writeArticleInfo():void	{
			var cursor : IIterator = this.articles.keyIterator();
			var key:String;
			var infoObj:Object;
			var ainfo:String = "";
			while(cursor.hasNext())	{
				key = cursor.next();
				infoObj = this.articles.itemFor(key);
				ainfo += infoObj.entry+"\n"
			}
			
			var afile : File = new File(this.infoUrl );
			var astrem : FileStream = new FileStream();
			
			astrem.open(afile,FileMode.WRITE);
			astrem.writeUTFBytes(ainfo);
			astrem.close();
			
		}
	}
}