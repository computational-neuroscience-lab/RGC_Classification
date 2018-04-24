macro "Recording PreProcessing [q]" {
	
	dir = getDirectory("luts");

	run("Duplicate...", "title=Traces duplicate");
	run("Gaussian Blur 3D...", "x=0 y=0 z=2");
	run("Set... ", "zoom=400 x=0 y=0");
        setLocation(15, 400); 

	run("Z Project...", "projection=[Standard Deviation]");
	run("LUT... ", "path=["+dir+"Red Hot.lut]"); 
	run("Set... ", "zoom=1200 x=0 y=0");
        setLocation(400, 200); 


	run("Synchronize Windows");
	selectWindow("Synchronize Windows");
        setLocation(1400, 100); 

	selectWindow("Traces");
	run("Plot Z-axis Profile");
        setLocation(1250, 400); 

	selectWindow("STD_Traces");
   	setTool("freehand");
}
