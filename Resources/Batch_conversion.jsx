
var scriptName = "conversion";


//===================================== FUNCTIONS  ======================================

function Main(str,device) {

	var folder =new Folder(str);
	var file, currentFile, doc, docName, newDocFile, increment,
	fileList = [],
	counter = 0;
	
	var inDesignVersion = Number(String(app.version).split(".")[0]);
	if (inDesignVersion < 5) {
		alert("This script is for InDesign CS3 and above.", scriptName, true);
		exit();
	}

	
	if (folder == null) exit();
   
	var allFilesList = folder.getFiles();

	for (var f = 0; f < allFilesList.length; f++) {
		file = allFilesList[f];
		if (file instanceof File && file.name.match(/\.i(nx|dml)$/i)) {
			fileList.push(file);
		}
	}
 getSubFolders(folder,fileList);
	if (fileList.length == 0) {
		alert("No files to open.", scriptName, true);
		exit();
	}


	
	app.scriptPreferences.userInteractionLevel = UserInteractionLevels.NEVER_INTERACT;

	var progressWin = new Window ("window", scriptName);
	var progressBar = progressWin.add ("progressbar", [12, 12, 350, 24], 0, fileList.length);
	var progressTxt = progressWin.add("statictext", undefined, "converting files for "+ device);
	progressTxt.bounds = [0, 0, 340, 20];
	progressTxt.alignment = "left";
	progressWin.show();
    
	for (var i = fileList.length-1; i >= 0; i--) {
		currentFile = fileList[i];
		
		try {
			doc = app.open(currentFile, false);
			docName = currentFile.name.replace(/\.i(nx|dml)$/i, ".indd");
			newDocFile = new File(currentFile.path + "/" + docName);
			
			

			progressBar.value = counter;
			progressTxt.text = String("Resaving file - " + docName + " (" + counter + " of " + fileList.length + ")");

			doc = doc.save(newDocFile);
			doc.close(SaveOptions.no);
			counter++;
		}
		catch(e) {}
	}

	progressWin.close();

	app.scriptPreferences.userInteractionLevel = UserInteractionLevels.INTERACT_WITH_ALL;

	var report = "device Name :" + device +" ->  " +counter + " files " + ((counter == 1) ? "was" : "were") + " resaved.";
	//alert("Finished. " + report, scriptName);
	return report;
}
  function getSubFolders( folder ,fileList){
        var allFilesList = folder.getFiles();
        for(var f=0;f<allFilesList.length;f++){
            file = allFilesList[f];
            if (file instanceof File && file.name.match(/\.i(nx|dml)$/i)) {
			fileList.push(file);
		}
            if(allFilesList[f] instanceof Folder){
                getSubFolders( allFilesList[f],fileList );
            }
        }
    };

