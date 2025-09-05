//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
// @String (label = "File suffix", value = ".nd2") fileSuffix
// @Double (label = "Maxima Prominence", value = 900) prominence

// cone_pedicle_count_batch
// Theresa Swayne for Siyuan Liu and Stephen Tsang, 2025
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
run("Clear Results");
roiManager("reset");

//setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
//print(year + "-" + (month+1)+ "-" + dayOfMonth + "_" + hour + "-" + minute);

// ---- Run ----

print("Starting");

processFolder(inputDir, outputDir, fileSuffix, prominence);

// save results and log with date-timestamp

saveAs("Results", outputDir + File.separator + year + "-" + (month+1)+ "-" + dayOfMonth + "_" + hour + "-" + minute + "_Results.csv" );

selectWindow("Log");
saveAs("Text", outputDir + File.separator + year + "-" + (month+1)+ "-" + dayOfMonth + "_" + hour + "-" + minute + "_Log.txt");

// ---- Clean up ----

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}


run("Clear Results");
roiManager("reset");

//setBatchMode(false);
print("Finished");


// ---- Functions ----

function processFolder(input, output, suffix, prominence) {
	filenum = -1;
	print("Processing folder", input, "using maxima prominence",prominence);
	// scan folder tree to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) {
			processFolder(input + File.separator + list[i], output, suffix);
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1; // usable files start wtih 0
			processFile(input, output, list[i], filenum, prominence);
		}
	}
}


function processFile(inputFolder, outputFolder, fileName, fileNumber, prominence) {
	
	path = inputFolder + File.separator + fileName;
	print("Processing file number",fileNumber," at path" ,path);	
	
	roiManager("reset");
	dotIndex = indexOf(fileName, "."); // limitation -- cannot have >1 dots in the filename
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	Ext.setId(path);
	//print("Processing file number",fileN, "with basename",basename);
	startTime = getTime();

	// open only channel 2
	run("Bio-Formats", "open=&path color_mode=Default specify_range view=Hyperstack stack_order=XYCZT c_begin=2 c_end=2 c_step=1");
	
	title = getTitle();
	
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
	//run("Invert");
	
	// preliminary selection of tissue
	selectWindow("blur");
	//doWand(5000, 5000, 20, "Legacy"); // set coords to be inside the tissue
	setAutoThreshold("Otsu dark");
	run("Create Selection");
	roiManager("Add");
	roiManager("select", 0);
	roiManager("rename", "whole tissue");
	
	// measure tissue area
	selectWindow(title);
	run("Set Measurements...", "area mean centroid display redirect=None decimal=3");
	roiManager("Select", 0);
	roiManager("Measure");
	
	// find maxima in original image
	selectWindow(title);
	run("Select None");
	run("Find Maxima...", "prominence=&prominence output=[Point Selection]");
	roiManager("Add");
	roiManager("select", 1);
	roiManager("rename", "cones");

	// *** get point selection properties (count)
	run("Properties... ", "show"); //  show the table of point counts (same as alt-Y)
	selectWindow("Counts_"+title); 
	lines = split(getInfo(), "\n");  // store all rows in an array
	// headings = split(lines[0], "\t"); // store the heading row in an array (optional)
	counterValues = split(lines[1], "\t");  // store the counter values in an array
	
	pointCount = counterValues[1]; // value of the first counter 
	
	// *** Add a column to results table to include the count
	selectWindow("Results");
	setResult("ConeCount", fileNumber, pointCount);
	updateResults();

	print("Elapsed time " + (getTime() - startTime) + " msec");
	
	// save the ROIs

	roiName = basename+"_RoiSet.zip";
	roiManager("deselect");
	roiManager("save", outputFolder + File.separator + roiName);
		
	selectWindow(title);
	//saveAs("tiff", outputFolder + File.separator + basename + "_thresh.tif" );
	close();
	
	selectWindow("blur");
	//saveAs("tiff", outputFolder + File.separator + basename + "_blur.tif" );
	close();
	
	selectWindow("Counts_"+title);
	run("Close");

} // process file

	