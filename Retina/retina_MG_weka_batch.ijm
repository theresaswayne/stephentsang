//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
//@File(label = "Weka classifier", style = "file") classifier
// @String (label = "File suffix", value = ".tif") fileSuffix

// retina_MG_weka_batch
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

run("Clear Results");
run("Set Measurements...", "area centroid perimeter shape area_fraction limit display redirect=None decimal=3");


// ---- Run ----

print("Starting");
processFolder(inputDir, outputDir, classifier, fileSuffix);
while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
//setBatchMode(false);
print("Finished");


// ---- Functions ----

function processFolder(input, output, model, suffix) {
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
			processFile(input, output, list[i], filenum, model);
		}
	}
}


function processFile(inputFolder, outputFolder, fileName, fileNumber, model) {
	
	path = inputFolder + File.separator + fileName;
	print("Processing file at path" ,path);	
	
	
	roiManager("reset");
	dotIndex = indexOf(fileName, "."); // limitation -- cannot have >1 dots in the filename
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	Ext.setId(path);
	print("Processing file",fileName, "with basename",basename);
	startTime = getTime();

	run("Bio-Formats", "open=&path color_mode=Default view=Hyperstack stack_order=XYCZT");
	title = getTitle();

	// run trainable weka pre-trained model

	run("Trainable Weka Segmentation");

	// wait for the plugin to load
	wait(3000);
	selectWindow("Trainable Weka Segmentation v4.0.0");
	call("trainableSegmentation.Weka_Segmentation.loadClassifier", model);
	call("trainableSegmentation.Weka_Segmentation.getResult");
	wait(3000);
	
	selectWindow("Classified image");
	setThreshold(1, 1);
	
	// analyze particles at least 100 µm2
	run("Analyze Particles...", "size=100-Infinity show=Nothing display exclude add");

	// save the ROIs and results
	roiName = basename+"_microglia_ROIset.zip";
	roiManager("deselect");
	roiManager("save", outputFolder + File.separator + roiName);
	
	saveAs("Results", outputFolder + File.separator + basename + "_microglia_results.csv");
	run("Clear Results");
	
	close();

	selectWindow(title);
	close();
		
	selectWindow("Classified image");
	saveAs("Tiff", outputFolder + File.separator + basename + "_classified.tif");
	close();
	
	print("Elapsed time " + (getTime() - startTime) + " msec");
	
} // process file

	