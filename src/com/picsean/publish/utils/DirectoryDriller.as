package com.picsean.publish.utils
{
	import com.picsean.publish.events.EventS3Bucket;
	import com.picsean.publish.logging.NativeAlert;
	import com.picsean.publish.model.vo.IDMLFileVO;
	
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import org.as3commons.collections.fx.LinkedMapFx;
	
	public class DirectoryDriller extends EventDispatcher
	{
		private var pendingListings:Number = 0;
		private var srcFiles : ArrayCollection = new ArrayCollection();
		private var directoryToSearch : Array;
		private var selectedPath : String;
		private var counter : Number = 0;
		private var assets : LinkedMapFx = new LinkedMapFx();
		private var jsons : LinkedMapFx = new LinkedMapFx();
		
		public function DirectoryDriller(target:IEventDispatcher=null)
		{
			super(target);
		}
		public function initialiseSearch():void	{
			this.srcFiles = new ArrayCollection();
			this.assets = new LinkedMapFx();
			this.directoryToSearch = new Array();
			this.counter = 0;
		}
		public function addDirectory(folder:Object):void	{
			directoryToSearch.push(folder);
		}
		public function start():void	{
			
			/*for(var i:Number =0; i<directoryToSearch.length; i++)	{
				trace(directoryToSearch[i].folder)
			}*/
			
			beginSearching(directoryToSearch[counter].folder)
		}
		private function beginSearching(folderPath:String) : void
		{
			selectedPath = folderPath;
			pendingListings += 1;
			var projectFolder:File = new File(folderPath.replace( IDMLFileVO.PATH_CONST,CookieHelper.getInstance().getWorkspace() )); //new implement
			var sourceFolder : File = projectFolder;//new File(folderPath);//projectFolder.resolvePath(projectFolder.url);
			
			if(!sourceFolder.exists)	{
				NativeAlert.show("Folder not found for the device "+directoryToSearch[counter].device.label)
				return;
			}
			sourceFolder.addEventListener( FileListEvent.DIRECTORY_LISTING, handleDirectoryListing );
			sourceFolder.getDirectoryListingAsync();
		}
		
		private function createResoucePath(filePath:String):String	{
			var directory_split : Array = selectedPath.split(File.separator);
			var rootIssuePath : String = directory_split[directory_split.length-1]
				
			var issuePath : String = directory_split[directory_split.length-2] + File.separator + rootIssuePath;
			var resourceUrl : String = filePath.substring(filePath.indexOf(issuePath));
			return resourceUrl;
		}
		
		private function createPubPath(p:String):String	{
			var pathSplit : Array = p.split(File.separator)
			return pathSplit[pathSplit.length - 3] + File.separator +
				pathSplit[pathSplit.length - 2] + File.separator + 
				pathSplit[pathSplit.length - 1];
		}
		
		private function handleDirectoryListing( event:FileListEvent ) : void
		{
			pendingListings -= 1;
			
			for each ( var item:File in event.files )
			{
				if( item.isDirectory )
				{
					item.getDirectoryListingAsync();
					pendingListings += 1;
					
					item.addEventListener( FileListEvent.DIRECTORY_LISTING, 
						handleDirectoryListing );
				}
				else if( item.extension == "jpg" || item.extension == "png" )
				{
					/*if(!isWellFormatedDirectory(item.url)){
						trace("Not Well formed")
						break
					}*/
					//srcFiles.addItem( item );
					this.assets.add(createResoucePath(item.url), item);
					//trace(srcFiles.length+"   "+item.name+"--------->  "+createResoucePath(item.url));
				}
				else if(item.extension == "json" || item.extension == "txt")	{
					this.jsons.add(createResoucePath(item.url), item);
				}
			}
			
			if( pendingListings == 0 )
			{
				//trace(counter)
				if(counter < directoryToSearch.length-1)	{
					counter ++;
					beginSearching(directoryToSearch[counter].folder)
				}
				else	{
					this.dispatchEvent(new EventS3Bucket(EventS3Bucket.EVENT_ASSETS_SEARCH_COMPLETED,{images : this.assets, jsons : jsons}));
				}
			}
		}
		
		private function isWellFormatedDirectory(pathName : String):Boolean	{
			var isFormed : Boolean = false;
			var portait : String = File.separator + "p" + File.separator;
			var landscape : String = File.separator + "l" + File.separator;
			var isPortrait : Number = pathName.indexOf(portait);
			var isLandScape : Number = pathName.indexOf(landscape);
			var commonDelimiter : String = "";
			commonDelimiter = ( isPortrait > 0  ? portait : "");
			commonDelimiter = ( isLandScape > 0   ? landscape : (isPortrait > 0 ? portait : "") );
			
			var deviceFolder : String = pathName.substring(0, pathName.indexOf(commonDelimiter));
			deviceFolder = deviceFolder.substring(deviceFolder.lastIndexOf( File.separator)+1);
			var dinfo : Object = directoryToSearch[counter].device;
			
			if(commonDelimiter != "" )	{
				if(dinfo.label != Configuration.DEVICE_IPAD && (deviceFolder.indexOf(dinfo.folder) >0 ))	{
					isFormed = true; 
				}
				if(dinfo.label == Configuration.DEVICE_IPAD){isFormed = true;}
				
			}
			else	{
				isFormed = false; 
			}
			
			return isFormed;
		}
		
		
	}
}