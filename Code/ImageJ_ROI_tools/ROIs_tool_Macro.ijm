macro "Recording PreProcessing [q]" {
	run("Duplicate...", "title=OriginalRecording duplicate");
	selectWindow("OriginalRecording");
        setLocation(10, 120); 
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("Z Project...", "projection=[Standard Deviation]");
     	setLocation(490, 120); 
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");

	selectWindow("OriginalRecording");
	run("Duplicate...", "title=ZBlurredRecording duplicate");
     	setLocation(10, 620); 
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");

	run("Gaussian Blur 3D...", "x=0 y=0 z=2");
	run("Z Project...", "projection=[Standard Deviation]");
        setLocation(490, 620); 
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");

	selectWindow("OriginalRecording");
	run("Plot Z-axis Profile");
        setLocation(910, 120); 
	selectWindow("ZBlurredRecording");
	run("Plot Z-axis Profile");
        setLocation(910, 620); 
	
	run("Synchronize Windows");
	selectWindow("Synchronize Windows");
        setLocation(1590, 120); 
	selectWindow("STD_ZBlurredRecording");
   	setTool("freehand");
}

