package com.picsean.publish.feature
{
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.adobe.indesign.TextFrame;
	import com.adobe.indesign.TextFrames;
	import com.adobe.serialization.json.JSON;
	import com.picsean.publish.core.FeatureFactory;
	import com.picsean.publish.model.LayoutVO;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.model.vo.BoundVO;
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;

	public class BaseFeature implements IFeature
	{
		public var group:Group;
		public var type: String;
		public var baseSubFeatures:LinkedMapFx =  new LinkedMapFx();
		public var boundvo:BoundVO;
		private static const GROUP_PROPERTIES  : String = "property";
		private static const TFRAME_NAME  : String = "pstring";
		
		
		public var subFeatures:LinkedMapFx = new LinkedMapFx();
		private var _directoryPath:String;
		private var _orientation:String;
		private var _name:String;
		private var _dpath:String;
		private var _layout:LayoutVO;
		private var _isInner : Boolean = false;
		private var _propertiesString : String;
		private var _isProperties : Boolean =  false;
		private var _isCorrupted : Boolean = false;
		
		private var _version:String;
		
		//for camera mask
		private var _maskPath:String;
		
		protected var exetension : String = ".png";
		protected var exetension_JPG : String = ".jpg";
		protected var serverURI:String;
		protected var logger:Logger;
		
		
		public function BaseFeature(grp:Group)
		{
			this.group = grp;
			logger = Log.getLogger(Configuration.PICSAEN_LOG);
			_version = PublishModel.getInstance().app.version;
			
			try { 
				PublishModel.getInstance().app.hostObjectDelegate.pngExportPreferences.transparentBackground = true;
			}catch(e:Error) {}
					
			
			
		}
		
		public function getBaseSubFeatures():void	{
			var allPage:Array = group.allPageItems as Array;
			var pgItem:PageItem;
			var bfeature:CommonFeature
			var txtCount:Number = 0;
			
			getPropertiesString()
			
			for(var i:Number = 0; i<allPage.length; i++)	{
				pgItem = allPage[i] as PageItem;
				bfeature = CommonFeatures.getLinks(pgItem,i,orientation,this.layout);if(bfeature != null){baseSubFeatures.add(bfeature.id,bfeature);} // Hyperlinks
				bfeature = CommonFeatures.getVideo(pgItem,i,directory,orientation,this.layout);if(bfeature != null){baseSubFeatures.add(bfeature.id,bfeature);} // Videos
				bfeature = CommonFeatures.getAudio(pgItem,i,directory,orientation,this.layout);if(bfeature != null){baseSubFeatures.add(bfeature.id,bfeature);} // Audio
				if (this.type == Configuration.MAIN || this.type == Configuration.TYPE_DRAW || this.type == Configuration.TYPE_PANORAMA){
				bfeature = CommonFeatures.getAnimatedImage(pgItem,i,directory,orientation,this.layout);if(bfeature != null){baseSubFeatures.add(bfeature.id,bfeature);}} // Animated image
				if (this.type == Configuration.MAIN){ bfeature = CommonFeatures.getZoomableImage(pgItem,i,directory,orientation,this.layout);if(bfeature != null){baseSubFeatures.add(bfeature.id,bfeature);}}///Zoomable image
				//if(pgItem is TextFrame)	{txtCount++; bfeature = CommonFeatures.getText(pgItem,txtCount);}if(bfeature != null){baseSubFeatures.add(bfeature.id,bfeature);} // Text
				bfeature = CommonFeatures.getWebOverView(pgItem, i, directory, orientation,this.layout);if( bfeature != null ){ baseSubFeatures.add( bfeature.id, bfeature );} // Weboverview
				bfeature = CommonFeatures.getScrubber(pgItem,i,directory,orientation,this.layout);if(bfeature != null){baseSubFeatures.add(bfeature.id,bfeature);} // scrubber
				bfeature = CommonFeatures.getJump(pgItem,i,directory,orientation,this.layout);if(bfeature !=null){baseSubFeatures.add(bfeature.id,bfeature);} //jump
				bfeature = CommonFeatures.getFlipImage(pgItem,i,directory,orientation,this.layout);if(bfeature !=null){baseSubFeatures.add(bfeature.id,bfeature);} //flipImage
			}
			
		}
		public function initFeature():void{
			getBaseSubFeatures();
		}
		
		protected function getPageItem(name:String):PageItem	{
			try	{
				if(this.group.pageItems.itemByName(name).isValid)	{
					return this.group.pageItems.itemByName(name) as PageItem;
				}
			}
			catch(error:Error)	{
				logger.error("Group "+name + "is not present in layer!");
			}
			return null;
		}
		
		protected function skipFeature(...args):Boolean	{
			for(var i:String in args)	{
				if( args[i] == null)	{
					return true;
				}
			}
			return false;
		}
		
		public function addSubFeatures(fName:String,gr:Group):void	{
			var sfeature:IFeature = FeatureFactory.createFeature(gr);
			sfeature.isInner = true;
			subFeatures.add(fName,sfeature);
		}
		

		
		public function getJSON():Object	{
			var jsonList:Array = new Array();
			var feature:IFeature;
			var iterator : IIterator = baseSubFeatures.keyIterator();
			
			while (iterator.hasNext()) {
				feature = baseSubFeatures.itemFor(iterator.next()) as IFeature;
				if(feature.featureType != null){
				jsonList.push(feature.getJSON());}
			}
			
			if(hasSubfeatures())	{
				iterator = subFeatures.keyIterator();
				while (iterator.hasNext()) {
					feature = subFeatures.itemFor(iterator.next()) as IFeature;
					if(feature.featureType != null){
					jsonList.push(feature.getJSON());}
				}
			}
			return jsonList;
		}
		
		
		public function createDirectory():void	{
			var pageDir : File = new File(this.directory);
			if (!pageDir.exists){
				pageDir.createDirectory();
			}
		}
		
		public function fixLocation(origin:BoundVO, bound:BoundVO):Object	{
			if(this.isInner)	{
				return origin.createBound();
			}
			return origin.createBound();
		}
		
		private function getPropertiesString():void	{
			var gps:Group;
			try	{
				if(group.pageItems.itemByName(GROUP_PROPERTIES))	{
					gps = group.groups.itemByName(GROUP_PROPERTIES);
					var allPage:Array = gps.allPageItems as Array;
					var pgItem : PageItem;
					for(var i:Number = 0; i<allPage.length; i++)	{
						pgItem = allPage[i] as PageItem;
						if(pgItem is TextFrame)	{
							var textFrame:TextFrame = pgItem as TextFrame;
							this.hasProperties = true;
							var kvstring : Array = (textFrame.contents).toString().split("|");
							var obj:Object = new Object();
							var valueString:Array;
							for(var k:int = 0; k<kvstring.length; k++)	{
								valueString = kvstring[k].split(":");
								valueString[1] = (valueString.length >2 ?  String(kvstring[k]).substring( String(kvstring[k]).indexOf(":")+1 ) : valueString[1]);
								trace(valueString[0] +"::::"+valueString[1])
								obj[valueString[0]] =  valueString[1];
							}
							this.propertyString = JSON.encode(obj);
						}
					}
					gps.visible = false;
				}
			}
			catch(error:Error)	{
				
			}
		}
		
		public function hasSubfeatures():Boolean	{	return (subFeatures.size > 0 ? true : false);	}
		
		public function get subFeatureList():LinkedMapFx	{	return this.subFeatures;	}
		
		public function get featureType():String	{	return this.type; }
		
		public function set directory(dir:String):void	{ this._directoryPath = dir; this.serverURI = getPublishServerURI(); 
		}
		public function get directory():String{	return _directoryPath; }

		public function set orientation(type:String):void {this._orientation = type};
		public function get orientation():String { return _orientation;};

		public function set name(n:String):void {this._name = n};
		public function get name():String { return _name;};

		public function set layout(l:LayoutVO):void {this._layout = l};
		public function get layout():LayoutVO { return _layout;};
		
		public function set isInner(i:Boolean):void	{this._isInner = i;}
		public function get isInner():Boolean {	return this._isInner;}
		
		public function set isCorrupted(v:Boolean):void	{this._isCorrupted = v;}
		public function get isCorrupted():Boolean {	return this._isCorrupted;}
		
		public function set maskPath(m:String):void	{this._maskPath = m;}
		public function get maskPath():String {	return this._maskPath;}
		
		public function set hasProperties(p:Boolean):void	{	this._isProperties = p;	}
		public function get hasProperties():Boolean	{	return this._isProperties;	}
		
		public function set propertyString(ps : String):void	{	this._propertiesString = ps;	}
		public function get propertyString():String	{	return this._propertiesString;	}
		
		public function toString():String	{
			return "{name : "+this.name+"} {type : "+this.type+"} {orient : "+this.orientation+"} {directory : .."+this.directory+"}"
		}
		
		public function toLCUrl(urlStr:String):String	{
			return String(urlStr).toLowerCase();
		}
		
		private function getPublishServerURI():String	{
			var layoutLiteral :String = File.separator + this.layout.orientation + File.separator;
			var pubPath : String = this.layout.publishDirectory  +this.directory.substring(this.directory.indexOf(layoutLiteral))
			var slicedpath:String = pubPath.substring(pubPath.indexOf("/"));
			var serverUri:String = String( Configuration.PICSEAN_SERVER_URL + slicedpath ).toLowerCase();
			
			return serverUri;
		}
	}
	
}