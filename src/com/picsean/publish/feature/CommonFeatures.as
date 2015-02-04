package com.picsean.publish.feature
{
	import com.adobe.indesign.ExportFormat;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.Line;
	import com.adobe.indesign.Lines;
	import com.adobe.indesign.PageItem;
	import com.adobe.indesign.TextFrame;
	import com.adobe.indesign.TextFrames;
	import com.adobe.indesign.Word;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.model.LayoutVO;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.model.vo.TextVO;
	import com.picsean.publish.utils.Configuration;
	import com.picsean.publish.utils.PageUtil;
	import com.picsean.publish.utils.StringHelper;
	
	import flash.filesystem.File;
	
	import mx.utils.StringUtil;
	
	import org.as3commons.collections.fx.LinkedMapFx;
	
	public class CommonFeatures 
	{
		//////////////////////////////////////////////////
		private  static var _model:PublishModel = PublishModel.getInstance();
		private static const LOCATION:String ='location';
		private static const TIMERDELAY:String = 'timerDelay';
		private static const TRIGGER:String ='trigger';
		private static const FEATURENAME_HYPERLINK :String ='hyperlink';
		private static const FEATURENAME_VIDEO:String ='video';
		private static const FEATURENAME_AUDIO :String ='audio';
		private static const FEATURENAME_ANIMIMAGE :String ='animimage';
		private static const ID:String ='id';
		private static const KEY :String= 'key'
		private static const VALUE:String ='value';
		private static const TYPE:String ='type';
		private static const TYPETEXT:String ='text';
		private static const LINES:String = 'lines';
		private static const ORIENTATION:String = 'orientation';
		private static const URL:String ='url';
		private static const IMAGE:String = 'image';
		private static const DURATION:String = 'duration';
		private static const SELECTEDTYPE:String = 'selectedtype';
		
		/////////////////////////////////////////////////////////
		
		public function CommonFeatures()
		{
		}
		
		public static function getLinks(item:PageItem,ids:int,orient:String, layout:LayoutVO):CommonFeature{
			var hyperLink:CommonFeature;
			var propstr:String = item.extractLabel(Configuration.LABEL);
			if(propstr.indexOf(Configuration.TYPE_IMAGEHYPERLINK)<0) return null
			//var data:Object = JSON.decode(propstr);
			/*var pageGr:Group
			var pageNum:String;
			pageGr = item.parent as Group;
			pageNum = pageGr.parentPage.name;*/
			var pageNum : String = String(Math.round((Math.random()*1000)) );
			var id:String = pageNum+"-"+FEATURENAME_HYPERLINK+"-"+ids;
			var bound:BoundVO = new BoundVO(item);
			var locationObj:Object = bound.createBound();
			//var data:Object = JSON.decode(item.extractLabel(Configuration.LABEL));
			var data:Object = JSON.decode(propstr);
			data[LOCATION] = locationObj.l;
			data[TRIGGER] = locationObj.t;
			data[ID] = id;
			data[ORIENTATION] = PageUtil.setOrientationType(orient);
			var str:String = JSON.encode(data);
			hyperLink = new CommonFeature(Configuration.TYPE_IMAGEHYPERLINK,id,str,bound, layout);
			return hyperLink;
		}
		
		public static function getVideo(item:PageItem,ids:int,pdir:String,orient:String, layout:LayoutVO):CommonFeature{
			var propstr:String = item.extractLabel(Configuration.LABEL);
		    if(propstr.indexOf(Configuration.TYPE_VIDEO) < 0) return null
			//var data:Object = JSON.decode(propstr);
			var videoFeature:CommonFeature;
			var pageGr:Group
			var pageNum:String;
			pageGr = item.parent as Group;
			pageNum = pageGr.parentPage.name;
			var id:String = pageNum+"-"+FEATURENAME_VIDEO+"-"+ids;
			var bound:BoundVO;
			if(!(item.parent is Group)){
				bound = new BoundVO(item);
			}else{
				bound = new BoundVO(item,item.parent as PageItem);
			}
			var locationObj:Object = bound.createBound();
			var pageDir:File = new File(pdir);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
			var slice:Array = pdir.split(File.separator);
			//var data:Object = JSON.decode(item.extractLabel(Configuration.LABEL));
			var data:Object = JSON.decode(propstr);
			if( data [TYPE] == Configuration.TYPE_VIDEO) data[TYPE] = 'video' else data[TYPE] = 'videotrigger';
			
			data[LOCATION] = locationObj.l;
			data[TRIGGER] = locationObj.l;
			data[ID] = id;
			data[ORIENTATION] = PageUtil.setOrientationType(orient);
			var videoF:File = new File(data['url'] as String);
			
			var fileLoc:File=new File(pageDir.url+File.separator+videoF.name);
			videoF.copyTo(fileLoc,true);
			var serveruri:String = PageUtil.getPublishServerURI(pdir) +videoF.name
			data[URL] = serveruri;
			
			var str:String;
			var timerStr:String = "";
			
			if(data[SELECTEDTYPE] == "timer"){
				
				data = PropertyWrapper.wrapTimer(data,data[TIMERDELAY]);
				timerStr = "timer";
				
			}else if(data[SELECTEDTYPE] == "animated"){
				
				data = PropertyWrapper.wrapAnimated(data,item,pageDir,PageUtil.getPublishServerURI(pdir));
				
			}
			
			delete data[SELECTEDTYPE];
			
			str = JSON.encode(data);
			
			videoFeature = new CommonFeature(Configuration.TYPE_VIDEO+timerStr,"v_"+ids, str,bound, layout);
			
			return videoFeature;
		}
		
		public static function getText(item:PageItem ,ids:int, layout:LayoutVO):CommonFeature{
			var textFeature:CommonFeature
			var data:Object = new Object()
			var txtProperty:Object = new Object();
			if(!item is TextFrame) return null;
			var textFrame:TextFrame = item as TextFrame;
			if(!textFrame.name=="duplicate");{
			data[TYPE] = "text";
			var textvo:TextVO = new TextVO(textFrame);
			data[LOCATION] = textvo.locationObj.l;
			var lines:Lines=textFrame.lines;
			txtProperty = textvo.getlines(lines);
			data[LINES] =txtProperty;
			var str:String = JSON.encode(data);
			textFeature = new CommonFeature(TYPETEXT, "t_"+ids, str,null, layout);}
			return textFeature;
		}
		
		public static function getAudio(item:PageItem,ids:int,pdir:String,orient:String, layout:LayoutVO):CommonFeature{
			var propstr:String = item.extractLabel(Configuration.LABEL);
			if(propstr.indexOf(Configuration.TYPE_AUDIO)<0) return null
			var data:Object = JSON.decode(propstr);
			var audioFeature:CommonFeature;
			var pageGr:Group
			var pageNum:String;
			pageGr = item.parent as Group;
			pageNum = pageGr.parentPage.name;
			var id:String = pageNum+"-"+FEATURENAME_AUDIO+"-"+ids;
			var bound:BoundVO;
			if(!(item.parent is Group)){
				bound = new BoundVO(item);
			}else{
				bound = new BoundVO(item,item.parent as PageItem);
			}
			var locationObj:Object = bound.createBound();
			var pageDir:File = new File(pdir);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
			//data[LOCATION] = data[TRIGGER] = locationObj.l;    //Bug 244 - Audio need not contain a "location" parameter
			data[TYPE] = 'audio'
			data[TRIGGER] = locationObj.l
			data[ID] = id;
			data[ORIENTATION] = PageUtil.setOrientationType(orient)
			
			var audioF:File = new File(data['url'] as String);
			var fileLoc:File=new File(pageDir.url+File.separator+audioF.name);
			audioF.copyTo(fileLoc,true);
			var serveruri:String = PageUtil.getPublishServerURI(pdir) +audioF.name
			data[URL] = serveruri;
			//var str:String = JSON.encode(data);
			
			var str:String;
			var timerStr:String = "";
			
			if(data[SELECTEDTYPE] == "timer"){
				
				data = PropertyWrapper.wrapTimer(data,data[TIMERDELAY]);
				timerStr = "timer";
				
			}else if(data[SELECTEDTYPE] == "animated"){
				
				data = PropertyWrapper.wrapAnimated(data,item,pageDir,PageUtil.getPublishServerURI(pdir));
				
			}
			
			delete data[SELECTEDTYPE];
			
			str = JSON.encode(data);
			
			audioFeature = new CommonFeature(Configuration.TYPE_AUDIO+timerStr, id, str,bound, layout);
			
			return audioFeature;
		}
		
		public static function getAnimatedImage(item:PageItem,ids:int,pdir:String,orient:String, layout:LayoutVO):CommonFeature{
			var propstr:String = item.extractLabel(Configuration.LABEL);
			if(propstr.indexOf(Configuration.TYPE_ANIMATEDIMAGE)<0) return null
			var data:Object = JSON.decode(propstr);
			var animFeature:CommonFeature
			var pageGr:Group
			var pageNum:String;
			pageGr = item.parent as Group;
			pageNum = pageGr.parentPage.name;
			var bound:BoundVO;
			if(!(item.parent is Group)){
				bound = new BoundVO(item);
			}else{
				bound = new BoundVO(item,item.parent as PageItem);
			}
			var locationObj:Object = bound.createBound();
			var pageDir:File = new File(pdir);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
			var id:String = pageNum+"-"+FEATURENAME_ANIMIMAGE+"-"+ids;
			data[LOCATION] = locationObj.l;
			data[ORIENTATION] = PageUtil.setOrientationType(orient)
			
			var gifF:File = new File(data['url'] as String);
			var fileLoc:File=new File(pageDir.url+File.separator+gifF.name);
			gifF.copyTo(fileLoc,true);
			var serveruri:String = PageUtil.getPublishServerURI(pdir) +gifF.name
			data[URL] = serveruri;
			var str:String = JSON.encode(data);
			animFeature = new CommonFeature(Configuration.TYPE_ANIMATEDIMAGE, id, str,bound, layout);
			return animFeature;
			
		}
		
		public static function getWebOverView(item:PageItem, id:int, pubDir:String, orient:String, layout:LayoutVO):CommonFeature	{
			var propertyStr : String = item.extractLabel( Configuration.LABEL );
			if(propertyStr.indexOf( Configuration.TYPE_WEBVIEW ) < 0 )	return null;
			var itemProps  : Object = JSON.decode( propertyStr ); // has the json as added in designer
			var locationObj : Object;
			
			var bound:BoundVO;
			if( !(item.parent is Group) ){ bound = new BoundVO( item );	}
			else{ bound = new BoundVO(item,item.parent as PageItem);	}
			locationObj = bound.createBound();
			
			itemProps.trigger = locationObj.l;
			itemProps.location = locationObj.t;
			itemProps.orientation = PageUtil.setOrientationType(orient);
			
			var webview:CommonFeature = new CommonFeature(Configuration.TYPE_WEBVIEW, 'webview_'+id, JSON.encode(itemProps),bound, layout);
			return webview;
			
		}
		
		public static function getZoomableImage(item:PageItem,id:int,pubDir:String,orient:String, layout:LayoutVO):CommonFeature{
			
			var propertyStr : String = item.extractLabel( Configuration.LABEL );
			if(propertyStr.indexOf( Configuration.TYPE_ZOOMABLEIMAGE ) < 0 )	return null;
			var data:Object = JSON.decode(propertyStr);
			var locationObj : Object;
			
			var bound:BoundVO;
			if( !(item.parent is Group) ){ bound = new BoundVO( item );	}
			else{ bound = new BoundVO(item,item.parent as PageItem);	}
			locationObj = bound.createBound();
			data.trigger = locationObj.l;
			data.location = locationObj.t;
			data.orientation = PageUtil.setOrientationType(orient);
			var pageDir:File = new File(pubDir);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
			var imgF:File = new File(data[IMAGE] as String);
			var fileLoc:File=new File(pageDir.url+File.separator+imgF.name);
			imgF.copyTo(fileLoc,true);
			var serveruri:String = PageUtil.getPublishServerURI(pubDir) +imgF.name
			data[IMAGE] = serveruri;
			var str:String = JSON.encode(data);
			var zoomableimage:CommonFeature = new CommonFeature(Configuration.TYPE_ZOOMABLEIMAGE,'zoom_'+id,str,bound, layout);
			return zoomableimage;
			
		}
		
		public static function getScrubber(item:PageItem,id:int,pubDir:String,orient:String, layout:LayoutVO):CommonFeature{
			var propertyStr : String = item.extractLabel( Configuration.LABEL );
			if(propertyStr.indexOf( Configuration.TYPE_SCRUBBEREFFECT ) < 0 )	return null;
			var bound:BoundVO;
			if(!(item.parent is Group)){
				bound = new BoundVO(item);
			}else{
				bound = new BoundVO(item,item.parent as PageItem);
			}
			var locationObj:Object = bound.createBound();
			var pageDir:File = new File(pubDir);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
			var data:Object = JSON.decode(propertyStr);
			data[LOCATION] = locationObj.l;
			data[TRIGGER] = locationObj.l;
			data[ORIENTATION] = PageUtil.setOrientationType(orient);
			var videoF:File = new File(data['url'] as String);
			var fileLoc:File=new File(pageDir.url+File.separator+videoF.name);
			videoF.copyTo(fileLoc,true);
			var serveruri:String = PageUtil.getPublishServerURI(pubDir) +videoF.name
			data[URL] = serveruri;
			var str:String = JSON.encode(data);
			var scrubber:CommonFeature = new CommonFeature(Configuration.TYPE_SCRUBBEREFFECT,'scrub_'+id,str,bound, layout);
			return scrubber;
		}
		
		public static function getJump(item:PageItem,id:int,pubDir:String,orient:String, layout:LayoutVO):CommonFeature{
			
			var propertystr:String = item.extractLabel(Configuration.LABEL);
			if(propertystr.indexOf( Configuration.TYPE_JUMP ) < 0 )	return null;
			var bound:BoundVO;
			if(!(item.parent is Group)){
				bound = new BoundVO(item);
			}else{
				bound = new BoundVO(item,item.parent as PageItem);
			}
			var locationObj:Object = bound.createBound();
			var data:Object = JSON.decode(propertystr);
			data[LOCATION] = locationObj.l;
			data[TRIGGER] = locationObj.t;
			data[ORIENTATION] = PageUtil.setOrientationType(orient);
			var str:String = JSON.encode(data);
			var jmp :CommonFeature = new CommonFeature (Configuration.TYPE_JUMP,'jump_'+id,str,bound, layout);
			return jmp;
		}
		
		public static function getFlipImage(item:PageItem,id:int,pubDir:String,orient:String,layout:LayoutVO):CommonFeature{
			
			var propertyStr : String = item.extractLabel( Configuration.LABEL );
			if(propertyStr.indexOf( Configuration.TYPE_FLIPIMAGE ) < 0 )	return null;
			var itemProps  : Object = JSON.decode( propertyStr ); // has the json as added in designer
			var locationObj : Object;
			var bound:BoundVO;
			if( !(item.parent is Group) ){ bound = new BoundVO( item );	}
			else{ bound = new BoundVO(item,item.parent as PageItem);	}
			locationObj = bound.createBound();
			itemProps.trigger = locationObj.l;
			itemProps.location = locationObj.t;
			itemProps.orientation = PageUtil.setOrientationType(orient);
			var pageDir:File = new File(pubDir);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
			var imgF:File = new File(itemProps.flipedImage as String);
			var fileLoc:File=new File(pageDir.url+File.separator+imgF.name);
			imgF.copyTo(fileLoc,true);
			var serveruri:String = PageUtil.getPublishServerURI(pubDir) +imgF.name
			itemProps.flipedImage = serveruri;
			
			var exportFile:File=new File(pageDir.url+File.separator+'flip_'+id+".jpeg");
			item.exportFile(ExportFormat.jpg, exportFile);
			itemProps.image =PageUtil.getPublishServerURI(pubDir) + exportFile.name;
			var flip:CommonFeature = new CommonFeature(Configuration.TYPE_WEBVIEW, 'flip_'+id, JSON.encode(itemProps),bound, layout);
			return flip;
			
		}
	}
}