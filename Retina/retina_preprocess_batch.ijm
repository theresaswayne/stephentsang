//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
// @String (label = "File suffix", value = ".nd2") fileSuffix

// retina_preprocess_batch
// Theresa Swayne for Tom Winogrodzki and Stephen Tsang, 2025
// 

// TO USE: Create a folder for the output files. 
// 	Run the script in Fiji. 
//  Limitation -- cannot have >1 dots in the filename


// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}
print("\\Clear"); // clear Log window

//setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files


// ---- Run ----

print("Starting");
processFolder(inputDir, outputDir, fileSuffix);
while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
//setBatchMode(false);
print("Finished");


// ---- Functions ----

function processFolder(input, output, suffix) {
	filenum = -1;
	print("Processing folder", input);
	// scan folder tree to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) {
			processFolder(input + File.separator + list[i], output, suffix);
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1;
			processFile(input, output, list[i], filenum);
		}
	}
}


function processFile(inputFolder, outputFolder, fileName, fileNumber) {
	
	path = inputFolder + File.separator + fileName;
	print("Processing file at path" ,path);	
	
	roiManager("reset");
	dotIndex = indexOf(fileName, "."); // limitation -- cannot have >1 dots in the filename
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	Ext.setId(path);
	print("Processing file",fileName, "with basename",basename);
	startTime = getTime();

	// open only channel 2
	run("Bio-Formats", "open=&path color_mode=Default specify_range view=Hyperstack stack_order=XYCZT c_begin=2 c_end=2 c_step=1");
	
	title = getTitle();
	
	// convert to 8-bit for local thresholding
	run("Green"); // LUT is weird sometimes upon import of image
	setOption("ScaleConversions", true);
	run("8-bit");
	run("Auto Local Threshold", "method=Niblack radius=15 parameter_1=0 parameter_2=0 white");
	run("Create Selection");
	roiManager("Add");
	roiManager("select", 0);
	roiManager("rename", "cones");
	
	// make a copy for whole-tissue detection 
	run("Select None");
	//run("Duplicate...", "title=blur"+title);
	run("Duplicate...", "title=blur");
	run("Gaussian Blur...", "sigma=10");
	
	// remove wrong-color borders
	run("Select All");
	run("Enlarge...", "enlarge=-20 pixel");
	setForegroundColor(0, 0, 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select None");
	run("Invert");
	
	// preliminary selection of tissue
	selectWindow("blur");
	doWand(5000, 5000, 20, "Legacy"); // set coords to be inside the tissue
	roiManager("Add");
	roiManager("select", 1);
	roiManager("rename", "whole tissue");
	
	print("Elapsed time " + (getTime() - startTime) + " msec");
	
	// save the ROIs and images

	roiName = basename+"_RoiSet.zip";
	roiManager("deselect");
	roiManager("save", outputFolder + File.separator + roiName);
		
	selectWindow(title);
	saveAs("tiff", outputFolder + File.separator + basename + "_thresh.tif" );
	close();
	
	selectWindow("blur");
	saveAs("tiff", outputFolder + File.separator + basename + "_blur.tif" );
	close();

} // process file

	