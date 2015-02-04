package com.picsean.publish.automation
{
	import com.picsean.publish.model.PublishModel;
	
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;

	public class DirectorySearchJson
	{
		private var currentNodes:Array = []; 
		private var directoryStack:Array = []; 
		private var currentSubdirectories:Array;
		private var nodeCount:uint = 0; 
		private var folderPath :String; 
		private var searchString : String = "po1.json";
		public var resultData:ArrayCollection= new ArrayCollection(); 
		private var pattern:RegExp; 
		public function DirectorySearchJson()
		{
			init();
		}
		private function init():void{
			folderPath=PublishModel.getInstance().directoryPath;
			search();
		}
		private function search():void {
			resultData = new ArrayCollection();
			searchkeyword(searchString);
			//searchkeyword(searchString);
		}
		private function searchkeyword(filetype:String):void{
			
			var patternString:String = filetype.replace(/\./g, "\\.");
			patternString = patternString.replace(/\*/g, ".*");
			patternString = patternString.replace(/\?/g, ".");
			pattern = new RegExp(patternString, "i");
			var dir:File = new File(folderPath);
			if (!dir.isDirectory){
			}
			else{
				dir.addEventListener(FileListEvent.DIRECTORY_LISTING, dirListed);
				dir.getDirectoryListingAsync();
			}
		}
		
		private function dirListed(event:FileListEvent):void {
			currentNodes = event.files;
			currentSubdirectories = [];
			nodeCount += currentNodes.length;
			trace( "Files and folders searched: " + nodeCount);
			var node:File;
			var fileExtension:String;
			for (var i:int = 0; i < currentNodes.length; i++) {
				node = currentNodes[i];
				if (node.isDirectory) {
					currentSubdirectories.push(currentNodes[i]);
				}if (node.name.search(pattern) > -1) {
					var newData:Object = {name:node.name,
						path:node.nativePath,
						type:node.extension}
					resultData.addItem(newData);
				}
			}
			for (i = currentSubdirectories.length - 1; i > -1; i--) {
				directoryStack.push(currentSubdirectories[i]);
			} 
			var dir:File = directoryStack.pop();
			if (dir == null) {
			} else {
				dir.addEventListener(FileListEvent.DIRECTORY_LISTING, dirListed);
				dir.getDirectoryListingAsync();
			}
		}
	}
}