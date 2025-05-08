// processing of retina single-channel images for cone quantitation

startTime = getTime();

title = getTitle();

// convert to 8-bit for local thresholding
run("Green"); // LUT is weird sometimes upon import of image
setOption("ScaleConversions", true);
run("8-bit");
run("Auto Local Threshold", "method=Niblack radius=15 parameter_1=0 parameter_2=0 white");
run("Create Selection");
roiManager("Add");

// make a copy for whole-tissue detection 
run("Select None");
run("Duplicate...", "title=blur"+title);
//run("Duplicate...", "title=blur");
run("Gaussian Blur...", "sigma=10");

// remove wrong-color borders
run("Select All");
run("Enlarge...", "enlarge=-20 pixel");
setForegroundColor(0, 0, 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select None");
run("Invert");

print("Elapsed time " + (getTime() - startTime) + " msec");
