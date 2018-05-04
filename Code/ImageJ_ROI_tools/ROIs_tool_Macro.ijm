macro "Recording PreProcessing [q]" {
	
	dir = getDirectory("luts");

	run("Duplicate...", "title=Traces duplicate");
	run("Gaussian Blur 3D...", "x=0 y=0 z=2");
	run("Set... ", "zoom=200 x=0 y=0");
        setLocation(15, 400); 

	run("Z Project...", "projection=[Standard Deviation]");
	run("LUT... ", "path=["+dir+"Cyan Hot.lut]"); 
	run("Set... ", "zoom=600 x=0 y=0");
        setLocation(400, 200); 


	run("Synchronize Windows");
	selectWindow("Synchronize Windows");
        setLocation(1200, 100); 

	run("Brightness/Contrast...");
        setLocation(1600, 50); 

	selectWindow("Traces");
	run("Plot Z-axis Profile");
        setLocation(1250, 400); 

	selectWindow("STD_Traces");
   	setTool("freehand");
}
