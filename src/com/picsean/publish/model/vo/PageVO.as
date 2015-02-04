package com.picsean.publish.model.vo
{
	import com.adobe.indesign.CoordinateSpaces;
	import com.adobe.indesign.Group;
	import com.adobe.indesign.Groups;
	import com.adobe.indesign.Page;
	import com.adobe.indesign.PageItem;
	import com.picsean.publish.core.FeatureFactory;
	import com.picsean.publish.events.EventFilePublish;
	import com.picsean.publish.events.EventTransporter;
	import com.picsean.publish.feature.AccelerometerTrigger;
	import com.picsean.publish.feature.AnimatedButtonFeature;
	import com.picsean.publish.feature.CameraFeature;
	import com.picsean.publish.feature.CommonFeature;
	import com.picsean.publish.feature.ConvertedPanoramaFeature;
	import com.picsean.publish.feature.DragImageFeature;
	import com.picsean.publish.feature.DrawFeature;
	import com.picsean.publish.feature.EventfullPanoramaFeature;
	import com.picsean.publish.feature.FlipBookFeature;
	import com.picsean.publish.feature.IFeature;
	import com.picsean.publish.feature.MainFeature;
	import com.picsean.publish.feature.PanoFeature;
	import com.picsean.publish.feature.PanoramaFeature;
	import com.picsean.publish.feature.RelativeDrag;
	import com.picsean.publish.feature.RelativeDraw;
	import com.picsean.publish.feature.RelativeImage;
	import com.picsean.publish.feature.RelativePanorama;
	import com.picsean.publish.feature.RelativePanoramaNew;
	import com.picsean.publish.feature.ScaleFeature;
	import com.picsean.publish.feature.ScrollFeature;
	import com.picsean.publish.feature.SlideShowFeature;
	import com.picsean.publish.feature.TimerJsonFeature;
	import com.picsean.publish.feature.TriggerablePanoramaFeature;
	import com.picsean.publish.model.LayoutVO;
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import org.as3commons.collections.LinkedMap;
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.fx.LinkedMapFx;
	import org.osmf.logging.Log;

	public class PageVO
	{
		public var page : Page;
		public var pagenum : int
		public var fileName : String;
		public var featureList : LinkedMapFx;
		public var json : LinkedMapFx;
		public var directoryPath : String
		public var orientation : String
		public var layout : LayoutVO;
		public var documentPath : String;
		
		public var isPano : Boolean = false;
		public var numPano : Number = 0;
		public var filePath : String;
		public var isLastPage : Boolean = false;
		public var isCorrupted : Boolean = false;
		
		
		private var items : Array;
		private var isPanoConversion : Boolean = false;
		private var convertedPano : ConvertedPanoramaFeature;
		
		
		public function PageVO(pg:Page, num:int, fname:String, orient:String, layout:LayoutVO)
		{
			this.page = pg;	
			this.pagenum = num;
			this.fileName = fname;
			this.filePath = fname;
			this.directoryPath = fname + File.separator;
			this.documentPath = fname + File.separator;
			this.orientation = orient;
			this.layout = layout;
			
			this.isPano = layout.isPanoPage();
			this.numPano = this.getNumPanos();
			
			
			
			populate()
		}
		/**
		 * Checking usecases for Panoramas
		 * 1 . Panorama with a group
		 * 2 . Panorama without a group (in this case, convert all pages to a panorama)
		 * 3 . Mutiple Panorma ( Create a parent pano and add all the panorama and featrues inside in it )
		 * */
		public function populate():void	{
			changeDirectoryForRetina()
			var isrl:Boolean;
			//Log.getLogger(Configuration.PICSAEN_LOG).info("PANO CHECK "+this.directoryPath)
			if( this.isPano && this.numPano == 1 )	{
				 // do normal
			}
			else if( this.isPano && this.numPano == 0)	{
				isrl = isRelativePano()
				if(!isrl){
				isPanoConversion = true; // pano page without a group, convert to pano
				convertedPano = createConvertedPanoPage( ConvertedPanoramaFeature.PANO_DEFAULT );}
			}
   			else if(this.isPano && this.numPano > 1)	{
				isrl = isRelativePano()
				if(!isrl){
				isPanoConversion = true; // convert to pano and add
				convertedPano = createConvertedPanoPage( ConvertedPanoramaFeature.PANO_MUTLI );}
			}
			else	{
				// do nothing 
			}
			trace("\n\n+++++++++++\n"+this.isPano+"::::"+this.fileName+"\n++++++++++++++\n\n")
			populateFeatureList();
			
			
		}
		
		private function isRelativePano():Boolean{
			
			var allGroups:Groups = page.groups as Groups;
			var gp:Group;
			var ftrName:String;
			for(var i:Number = 0; i<allGroups.count(); i++)	{
				gp = Group(allGroups.item(i));
				ftrName = PageItem(gp).name;
				if(ftrName != Configuration.TYPE_RELATIVE_PANORAMA_NEW)	{
					return false;
				}
				}
			return true;
		}
		private function changeDirectoryForRetina():void	{
			if(this.layout.device != Configuration.DEVICE_IPAD_RETINA)	{
				return
			}
			var layoutLiteral : String = File.separator + this.layout.orientation + File.separator;
			var directoryLayout : String = this.directoryPath.substring(0,this.directoryPath.indexOf(layoutLiteral));
			var directoryPublish : String = this.directoryPath.substring(this.directoryPath.indexOf(layoutLiteral));
			var newPath :String = directoryLayout + Configuration.IPAD_RETINA_LITERAL_PUBLISH +  directoryPublish ;
			
			this.layout.publishDirectory = this.layout.publishDirectory + Configuration.IPAD_RETINA_LITERAL_PUBLISH;
			this.filePath = directoryLayout + Configuration.IPAD_RETINA_LITERAL_PUBLISH + directoryPublish.substring(0,directoryPublish.length-1);
			this.directoryPath = newPath;
		}
		private function rePopulateForRelative():void	{
			if( this.filePath.indexOf("p01") >=0){
				PublishModel.getInstance().replativePanoPO.addItem({path:this.filePath,name:this.fileName});
			}
			featureList = new LinkedMapFx();
			var allGroups:Groups = page.groups as Groups;
			var gp:Group,gpInner:Groups;
			var ftrName:String;
			var feature:IFeature;
			
			for(var i:Number = 0; i<allGroups.count(); i++)	{
				gp = Group(allGroups.item(i));
				
					ftrName = PageItem(gp).name;
					if(ftrName != Configuration.MAIN)	{
					feature = FeatureFactory.createFeature(gp);
					feature.layout = this.layout;
					feature.directory = this.directoryPath;
					feature.orientation = this.orientation;
					feature.name = ftrName;
					if(gp.groups.count() > 0 && ftrName.split("-")[0] == Configuration.TYPE_PANORAMA || Configuration.TYPE_PANO)	{
						//passing the content group inside the feature 
						/* Nested pano : added one more group for nested pano.in the group strcuture "nested" group should be added only for nested pano.
						will remove this when we have better solution.
						*/
						
						
							gpInner = Groups(gp.groups.itemByName("clubedPano").groups);}
							var innerFeature:Object = getNestedFeature(gpInner);
							var innerlist : ArrayCollection = innerFeature.list;
							var sfeature : Object;
							for(var f:Number = 0; f<innerlist.length; f++)	{
								sfeature = innerlist[f];
								feature.addSubFeatures(sfeature.name,sfeature.data as Group)
							}
					feature.initFeature();
					
					featureList.add(feature.name, feature );
					
				}
			}
			
		}
		private function populateFeatureList():void	{
			featureList = new LinkedMapFx();
			var bool :Boolean = false;
			var allGroups:Groups = page.groups as Groups;
			var gp:Group,gpInner:Groups;
			var ftrName:String;
			var feature:IFeature;
			for(var i:Number = 0; i<allGroups.count(); i++)	{
				gp = Group(allGroups.item(i));
				ftrName = PageItem(gp).name;
				
				if(Configuration.getFeatureType(ftrName) == Configuration.TYPE_RELATIVE_PANORAMA_NEW)	{
					rePopulateForRelative();
					bool = true;
					break;
				}
				
				feature = FeatureFactory.createFeature(gp);
				feature.layout = this.layout;
				feature.directory = this.directoryPath;
				feature.orientation = this.orientation;
				feature.name = ftrName;
				
				/** checking whether the group is of a nested item -- normale case scenario pano->pano  (FROM Content)
				**  Checking only Panorama for inner features 
				 **/
				if(gp.groups.count() > 0 && ftrName.split("-")[0] == Configuration.TYPE_PANORAMA || Configuration.TYPE_PANO)	{
					//passing the content group inside the feature 
					/* Nested pano : added one more group for nested pano.in the group strcuture "nested" group should be added only for nested pano.
					will remove this when we have better solution.
					*/
					if(gp.groups.itemByName(Configuration.G_NESTED).isValid){
						gpInner = Groups(gp.groups.itemByName(Configuration.G_NESTED).groups);
					}else{
					gpInner = Groups(gp.groups.itemByName(Configuration.G_CONTENT).groups);}
					var innerFeature:Object = getNestedFeature(gpInner);
					if(innerFeature.present)	{
						var innerlist : ArrayCollection = innerFeature.list;
						var sfeature : Object;
						for(var f:Number = 0; f<innerlist.length; f++)	{
							sfeature = innerlist[f];
							feature.addSubFeatures(sfeature.name,sfeature.data as Group)
						}
					}
				}
				/**
				 * if the page is a Pano, 
				 * pano conversion occurs, add all features as subfeature to Main Pano page
				 **/
				if(!isPanoConversion)	{
					feature.initFeature();
					featureList.add(ftrName,feature);
				}
				else	{
					convertedPano.addToSubFeature(ftrName, feature);
				}
				
			}
			if( bool == true){
				return
			}
			/**
			 * getting base features from main group and add that into featureList ( all execpt converted pano )
			 * In converted pano get the subFeature main and do the rest 
			 */
			
			var mainFeature:MainFeature;
			if(!isPanoConversion)	{	mainFeature = MainFeature(featureList.itemFor(Configuration.MAIN));	}
			else				{
				// if only main calling initFeature, while page is pano;
				// this is to get the subfeatures/base features of main
				mainFeature = MainFeature(convertedPano.subFeatureList.itemFor(Configuration.MAIN));
				mainFeature.initFeature();
			}
			
			// checking items in MAIN
			var mainGroupFeature:LinkedMapFx = mainFeature.baseSubFeatures;
			var miterator:IIterator = mainGroupFeature.keyIterator();
			var key:String;
			var commonFeature:CommonFeature;
			while(miterator.hasNext())	{
				key = miterator.next();
				commonFeature =  mainGroupFeature.itemFor(key);
				commonFeature.shiftPosition( mainFeature.group.visibleBounds as Array, this.layout);
				if(!isPanoConversion)	{	this.featureList.add(commonFeature.id, commonFeature);	}
				else				{	this.convertedPano.addBaseSubFeatures(commonFeature.id, commonFeature);	}
			}
			///
			// after getting all the features from main add all those features into the page features
			//and then remove MAIN from featureList
			if(!isPanoConversion)	{	featureList.removeKey(Configuration.MAIN);	}
			else	{
				featureList = new LinkedMapFx();
				this.convertedPano.subFeatureList.removeKey( Configuration.MAIN );// removing main from subfeatures list in converted pano
				convertedPano.initFeature();
				featureList.add(convertedPano.name, convertedPano );
			}
			
			items = featureList.keysToArray();
			
			
			/* this is to skip unwanted groups.*/
			var pocArr:Array = featureList.keysToArray();
			
			if(pocArr.toString().indexOf("group") != -1)
			{
				for(var j:int = 0; j<items.length; j++)
				{
					if((items[j] as String).indexOf("group") != -1)	{
						featureList.removeKey(items[j]);
					}
				}
			}
			
			Log.getLogger(Configuration.PICSAEN_LOG).info("Orientation : "+this.orientation + "    Number of pages       " + (this.pagenum + 1) + " completed")
						//Log.getLogger(Configuration.PICSAEN_LOG).info("\n {0} These features will be published on the page \n ____________________________________",items)
		}
		
		private function getNestedFeature(gp:Groups):Object	{
			// for safer side returning the object with boolean 
			var returnObj:Object = {present:false,list:new ArrayCollection()};
			if(gp == null){return returnObj;}
			for(var i:Number = 0; i<gp.count(); i++)	{
				//again checking the item is of a nested item
				if(Configuration.isNested(gp.item(i).name))	{
					returnObj.list.addItem({name:gp.item(i).name, data: gp.item(i) as Group})
					returnObj.present = true;
				}
			}
			return returnObj;
		}
		
		public function invokeHandler():void{
			EventTransporter.getInstance().dispatchEvent(new EventFilePublish(EventFilePublish.EVENT_PAGE_PUBLISH,this));
		}

		/**
		 * Bad hack for showing all the triggers in DRAW and DRAWCLOSE
		 * while the main/page exported as image
		 * 
		 * TODO :  Check the innner DRAW and DRAWCLOSE inside PANORAMA
		 * 
		 * */
		public function enableDrawFeatures(isShow:Boolean):void	{ 
			
			if(this.isPano)	{
				this.reframePage(!isShow);
			}
			
			
			var iterator:IIterator = featureList.keyIterator();
			var feature:IFeature;
			
			var fdraw:DrawFeature;
			var slideshow:SlideShowFeature;
			var scroll:ScrollFeature;
			var aniBtn:AnimatedButtonFeature;
			var fpano:PanoramaFeature;
			var fnewpano :PanoFeature;
			var scale:ScaleFeature;
			var dragImg:DragImageFeature;
			var timerjson:TimerJsonFeature;
			var trPano : TriggerablePanoramaFeature;
			var evntPano : EventfullPanoramaFeature;
			var accelMtr : AccelerometerTrigger
			var relativePano : RelativePanorama;
			var camFeature : CameraFeature;
			var rdraw :RelativeDraw;
			var rimage:RelativeImage;
			var rDrag:RelativeDrag;
			var relativePanonew: RelativePanoramaNew;
			var flipBook : FlipBookFeature;
			
			while(iterator.hasNext())	{
				feature = featureList.itemFor(iterator.next()) as IFeature;
				if(feature.isCorrupted){this.isCorrupted = true;}
				
				if(feature.featureType == Configuration.TYPE_DRAW)	{
					fdraw = feature as DrawFeature;
					fdraw.badHide(isShow,Configuration.TYPE_DRAW);
				}
				if(feature.featureType == Configuration.TYPE_SLIDESHOW){
					slideshow = feature as SlideShowFeature;
					slideshow.badHide(isShow,Configuration.TYPE_SLIDESHOW);
				}
				if(feature.featureType == Configuration.TYPE_SCROLL){
					scroll = feature as ScrollFeature;
					scroll.badHide(isShow,Configuration.TYPE_SCROLL);
				}
				if(feature.featureType == Configuration.TYPE_ANIMBTN){
					aniBtn = feature as AnimatedButtonFeature;
					aniBtn.badHide(isShow,Configuration.TYPE_ANIMBTN);
				}
				if(feature.featureType == Configuration.TYPE_PANORAMA){
					fpano = feature as PanoramaFeature;
					fpano.badHide(isShow, Configuration.TYPE_PANORAMA)
				}
				if(feature.featureType == Configuration.TYPE_SCALE){
					scale = feature as ScaleFeature;
					scale.badHide(isShow,Configuration.TYPE_SCALE);
				}
				if(feature.featureType == Configuration.TYPE_TIMERJSON){
					timerjson = feature as TimerJsonFeature;
					timerjson.badHide(isShow,Configuration.TYPE_TIMERJSON);
				}
				if(feature.featureType == Configuration.TYPE_TRIGGERABLEPANO){
					trPano = feature as TriggerablePanoramaFeature;
					trPano.badHide(isShow,Configuration.TYPE_TRIGGERABLEPANO);
				}
				if(feature.featureType == Configuration.TYPE_DRAGIMAGE){
					dragImg = feature as DragImageFeature;
					dragImg.badHide(isShow,Configuration.TYPE_DRAGIMAGE);
				}
				if(feature.featureType == Configuration.TYPE_PANORAMA_EVENT){
					evntPano = feature as EventfullPanoramaFeature;
					evntPano.badHide(isShow,Configuration.TYPE_PANORAMA_EVENT);
				}
				if(feature.featureType == Configuration.TYPE_ACCELEROMETERTRIGGER){
					accelMtr = feature as AccelerometerTrigger;
					accelMtr.badHide(isShow,Configuration.TYPE_ACCELEROMETERTRIGGER);
				}
				if(feature.featureType == Configuration.TYPE_RELATIVE_PANORAMA){
					relativePano = feature as RelativePanorama;
					relativePano.badHide(isShow,Configuration.TYPE_RELATIVE_PANORAMA);
				}
				if(feature.featureType == Configuration.TYPE_CAMERA){
					camFeature = feature as CameraFeature;
					camFeature.badHide(isShow,Configuration.TYPE_CAMERA);
				}
				if(feature.featureType == Configuration.TYPE_RELATIVE_DRAW){
					rdraw = feature as RelativeDraw;
					rdraw.badHide(isShow,Configuration.TYPE_CAMERA);
				}
				if(feature.featureType == Configuration.TYPE_RELATIVE_IMAGE){
					rimage = feature as RelativeImage;
					rimage.badHide(isShow,Configuration.TYPE_RELATIVE_IMAGE);
				}
				if(feature.featureType == Configuration.TYPE_RELATIVE_DRAG){
					rDrag = feature as RelativeDrag;
					rDrag.badHide(isShow,Configuration.TYPE_RELATIVE_DRAG);
				}
				if(feature.featureType == Configuration.TYPE_PANO){
					fnewpano = feature as PanoFeature;
					fnewpano.badHide(isShow,Configuration.TYPE_PANO);
				}
				if(feature.featureType == Configuration.TYPE_RELATIVE_PANORAMA_NEW){
					relativePanonew = feature as RelativePanoramaNew;
					relativePanonew.badHide(isShow,Configuration.TYPE_RELATIVE_PANORAMA_NEW);
				}
				if(feature.featureType == Configuration.TYPE_FLIP_BOOK){
					flipBook = feature as FlipBookFeature;
					flipBook.badHide(isShow,Configuration.TYPE_FLIP_BOOK);
				}
			}
		}
		/**
		 * Chopping the page for priting while its a pano page
		 * And setting back to the normal size after print published
		 * **/
		private function reframePage(doChop:Boolean):void	{
			var cropPage : Object;
			if(doChop)	{
				//hack for ipad
				cropPage  = (layout.ratio == 2 ? {w:layout.width*2,h:layout.height*2} : {w:layout.width, h:layout.height});
				page.reframe(CoordinateSpaces.INNER_COORDINATES, [[0,0],[cropPage.w, cropPage.h]]);
			}
			else	{
				page.reframe(CoordinateSpaces.INNER_COORDINATES, [[0,0],[layout.pageDimension.x, layout.pageDimension.y]]);
			}
		}
		/**
		 * Checking number of panos present in the group
		 * if its mutiple pano, make that as subfeatures
		 * */
		
		private function getNumPanos():Number	{
			var panCount:Number = 0;
			var allGroups:Groups = page.groups as Groups;
			var ftrName : String;
			var gp : Group;
			if(allGroups.count() <= 0) return 0;
			for(var i:Number = 0; i<allGroups.count(); i++)	{
				gp = Group(allGroups.item(i));
				ftrName = PageItem(gp).name;
				if(ftrName.split("-")[0] == Configuration.TYPE_PANORAMA)	{
					panCount ++;
				}
			}
			return panCount;
		}
		
		private function createConvertedPanoPage(panType:String):ConvertedPanoramaFeature	{
			var cp : ConvertedPanoramaFeature = new ConvertedPanoramaFeature(Configuration.TYPE_PANORAMA, panType,  this.page, 
				Configuration.TYPE_PANORAMA + "-100", this.directoryPath, this.orientation, this.layout);
			
			return cp;
		}
	}
}