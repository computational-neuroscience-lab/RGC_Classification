package org.institut_vision.imagej;

import ij.*;
import ij.gui.Plot;
import ij.gui.GenericDialog;
import ij.plugin.filter.PlugInFilter;
import ij.process.ImageProcessor;
import ij.process.ByteProcessor;
import ij.gui.Roi;
import ij.gui.Overlay;
import ij.io.OpenDialog;

import java.awt.*;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.LinkedList;
import ij.util.StringSorter;
import java.util.Vector;

import hdf.hdf5lib.H5;
import hdf.hdf5lib.HDF5Constants;

/**
 *  An ImageJ plugin to extract luminescent patterns from cell recordings.
 */
public class Extract_ROIs_h5 implements PlugInFilter {

	//-------------------------------------------------------//
	//						CONSTANTS						 //
	//-------------------------------------------------------//

	private static final String DEFAULT_EXP_NAME = "TracesData";

	//-------------------------------------------------------//
	//					PUBLIC FUNCTIONS					 //
	//-------------------------------------------------------//

	@Override
	public int setup(String arg, ImagePlus imp) {
		if (arg.equals("about")) {
			IJ.showMessage("Extract ROIs to .h5", "a plugin to export ROIs to .h5 files");
			return DONE;
		}
		return DOES_8G | DOES_16 | DOES_32 | DOES_RGB;
	}

	@Override
	public void run(ImageProcessor ip) {
		ImagePlus roiImage = IJ.getImage();
		int width = roiImage.getWidth();
		int height = roiImage.getHeight();

		// Get the overlay
		Overlay overlay = roiImage.getOverlay();
		if (overlay == null) {
			IJ.error("Error", "Overlay required");
			return;
		}
		IJ.showMessage("Extract ROIs to .h5", overlay.size() + " ROIs have been selected");

		// Select the stacks from which to extract the cell patterns
//		String[] suitableStacks = this.getAvailableStacks(width, height);
//		if (suitableStacks == null) {
//			IJ.error(" Error", "No stacks available (" + width + "x" + height + ") to use");
//			return;
//		}
//		DialogOutput dialogOutput = this.showSelectionDialog(suitableStacks);
		DialogOutput dialogOutput = this.showSelectionDialog(new String[0]);
//		List<String> selectedStacksIDs = dialogOutput.getSelectedStacksIDs();
		String experimentId = dialogOutput.getExperimentId();
//		if (selectedStacksIDs == null) {
//			return;
//		}

		// Extract the cell patterns
		Map<String, double[][]> stackId2patterns = new HashMap<String, double[][]>();
//		for (String stackName : selectedStacksIDs) {
//			ImageStack stack = WindowManager.getImage(stackName).getStack();
//			double[][] patterns = this.getCellPatterns(overlay, stack);
//
//			String stackId = stackName;
//			if (stackId.indexOf(".") > 0) {stackId = stackId.substring(0, stackId.lastIndexOf("."));}
//			stackId2patterns.put(stackId, patterns);
//		}

		// Compute the cell masks:
		ImagePlus[] cellMasks = this.getCellMasks(overlay, width, height);

		// Compute the cell centers
		double[][] cellCentroids = this.getCellCentroids(overlay);

		// Save in the .h5 file
		OpenDialog openDialog = new OpenDialog("Where do you want to save your data?");
		String path = openDialog.getDirectory();
		if (path != null) {
			String h5fileName = path + experimentId + ".h5";
			this.exportDataH5(h5fileName, stackId2patterns, cellCentroids, cellMasks);

			GenericDialog gd = new GenericDialog("Extract ROIs to .h5");
			gd.addMessage("Data succesfully exported to " + h5fileName);
			gd.showDialog();
		}

		// Plots
//		for(Map.Entry<String, double[][]> entry : stackId2patterns.entrySet()) {
//			String stackId = entry.getKey();
//			double[][] patterns = entry.getValue();
//			this.plotSignals(stackId, patterns);
//		}
//		for (int i = 0; i < cellMasks.length; i++) {
//			cellMasks[i].show();
//		}
	}


	//-------------------------------------------------------//
	//					PRIVATE FUNCTIONS					 //
	//-------------------------------------------------------//

	private String[] getAvailableStacks (int width, int height) {
		int[] stacksIndexes = WindowManager.getIDList();
		Vector stacksList = new Vector(stacksIndexes.length);

		// look for stacks of the given dimensions
		for (int i = 0; i < stacksIndexes.length; i++) {
			ImagePlus imp = WindowManager.getImage(stacksIndexes[i]);
			if (imp.getWidth() == width && imp.getHeight()== height && imp.getImageStackSize()>1) {
				String name = imp.getTitle();
				if (!stacksList.contains(name))
					stacksList.addElement(name);
			}
		}
		if (stacksList.size() == 0) {
			return null;
		}
		String[] suitableImages = new String[stacksList.size()];
		for (int i=0; i<stacksList.size(); i++) {
			suitableImages[i] = (String)stacksList.elementAt(i);
		}
		StringSorter.sort(suitableImages);
		return suitableImages;
	}

	private ImagePlus[] getCellMasks(Overlay overlay, int width, int height) {
		ImagePlus[] cellMasks = new ImagePlus[overlay.size()];
		for (int i = 0; i < cellMasks.length; i++) {
			Roi roi = overlay.get(i);
			ByteProcessor bp = new ByteProcessor(width, height);
			for (Point p : roi) {
				bp.putPixel(p.x, p.y, 255);
			}
			cellMasks[i] = new ImagePlus("Cell " + (i + 1), bp);
		}
		return cellMasks;
	}

	private double[][] getCellCentroids(Overlay overlay) {
		double[][] cellCenters = new double[2][];
		cellCenters[0] = new double[overlay.size()];
		cellCenters[1] = new double[overlay.size()];

		for(int n_ROI=0; n_ROI<overlay.size(); n_ROI++) {
			Roi roi = overlay.get(n_ROI);
			cellCenters[0][n_ROI] = roi.getContourCentroid()[0];
			cellCenters[1][n_ROI] = roi.getContourCentroid()[1];
		}
		return cellCenters;
	}

	private double[][] getCellPatterns(Overlay overlay, ImageStack stack) {
		// Initialize
		double[][] patterns = new double[overlay.size()][];
		for (int i = 0; i < overlay.size(); i++) {
			patterns[i] = new double[stack.size()];
		}

		// Extract
		for (int n_slice = 0; n_slice < stack.size(); n_slice++) {
			ImageProcessor slice = stack.getProcessor(n_slice + 1);
			for (int n_ROI = 0; n_ROI < overlay.size(); n_ROI++) {
				Roi roi = overlay.get(n_ROI);
				double average_luminescence = 0;
				for (Point p : roi) average_luminescence += slice.get(p.x, p.y);
				average_luminescence /= roi.getContainedFloatPoints().npoints;
				patterns[n_ROI][n_slice] = average_luminescence;
			}
		}
		return patterns;
	}

	private double[][][] cellMasksToMatrix(ImagePlus[] cellMasks) {
		double[][][] cellMasksMatrix = new double[cellMasks.length][][];
		for (int n_cell = 0; n_cell < cellMasks.length; n_cell++) {
			cellMasksMatrix[n_cell] = new double[cellMasks[n_cell].getWidth()][];
			for (int x = 0; x < cellMasks[n_cell].getWidth(); x++) {
				cellMasksMatrix[n_cell][x] = new double[cellMasks[n_cell].getHeight()];
				for (int y = 0; y < cellMasks[n_cell].getHeight(); y++) {
					cellMasksMatrix[n_cell][x][y] = cellMasks[n_cell].getPixel(x, y)[0] / 255;
				}
			}
		}
		return cellMasksMatrix;
	}

	private void exportDataH5(String fileName, Map<String, double[][]> stackId2patterns,
							  double[][] cellCentroids, ImagePlus[] cellMasks) {
//		if (stackId2patterns.entrySet().size() == 0 || cellCentroids.length == 0 || cellMasks.length == 0 ) {
//			return;
//		}

		double[][][] cellMasksMatrix = this.cellMasksToMatrix(cellMasks);

		try {
			int fileId = H5.H5Fcreate(fileName,	HDF5Constants.H5F_ACC_TRUNC, HDF5Constants.H5P_DEFAULT,
					HDF5Constants.H5P_DEFAULT);

			// Create and fill datasets for Cell masks and centroids
			long[] dimCentroids = {cellCentroids.length, cellCentroids[0].length};
			long[] dimMasks = {cellMasks.length, cellMasks[0].getWidth(), cellMasks[0].getHeight()};

			int spaceCentroidsId = H5.H5Screate_simple(2, dimCentroids, null);
			int spaceMasksId = H5.H5Screate_simple(3, dimMasks, null);

			int dataSetCentroidsId = H5.H5Dcreate(fileId, "centroids", HDF5Constants.H5T_NATIVE_DOUBLE, spaceCentroidsId,
					HDF5Constants.H5P_DEFAULT, HDF5Constants.H5P_DEFAULT, HDF5Constants.H5P_DEFAULT);
			int dataSetMasksId = H5.H5Dcreate(fileId, "masks", HDF5Constants.H5T_NATIVE_DOUBLE, spaceMasksId,
					HDF5Constants.H5P_DEFAULT, HDF5Constants.H5P_DEFAULT, HDF5Constants.H5P_DEFAULT);

			H5.H5Dwrite(dataSetCentroidsId, HDF5Constants.H5T_NATIVE_DOUBLE, HDF5Constants.H5S_ALL, HDF5Constants.H5S_ALL,
					HDF5Constants.H5P_DEFAULT, cellCentroids);
			H5.H5Dwrite(dataSetMasksId, HDF5Constants.H5T_NATIVE_DOUBLE, HDF5Constants.H5S_ALL, HDF5Constants.H5S_ALL,
					HDF5Constants.H5P_DEFAULT, cellMasksMatrix);

			// Create a group for each stack and put there the corresponding patterns data
//			for(Map.Entry<String, double[][]> entry : stackId2patterns.entrySet()) {
//				String stackId = entry.getKey();
//				double[][] patterns = entry.getValue();
//
//				// Create the group
//				int groupId = H5.H5Gcreate(fileId, stackId,
//						HDF5Constants.H5P_DEFAULT, HDF5Constants.H5P_DEFAULT, HDF5Constants.H5P_DEFAULT);
//
//				// Add the patterns dataset
//				long[] dimPatterns = {patterns.length, patterns[0].length};
//				int spacePatternsId = H5.H5Screate_simple(2, dimPatterns, null);
//				int dataSetPatternsId = H5.H5Dcreate(groupId, "traces", HDF5Constants.H5T_NATIVE_DOUBLE, spacePatternsId,
//						HDF5Constants.H5P_DEFAULT, HDF5Constants.H5P_DEFAULT, HDF5Constants.H5P_DEFAULT);
//				H5.H5Dwrite(dataSetPatternsId, HDF5Constants.H5T_NATIVE_DOUBLE,
//						HDF5Constants.H5S_ALL, HDF5Constants.H5S_ALL, HDF5Constants.H5P_DEFAULT, patterns);
//
//				// close everything
//				H5.H5Gclose(groupId);
//				H5.H5Dclose(dataSetPatternsId);
//				H5.H5Sclose(spacePatternsId);
//			}

			// close everything
			H5.H5Dclose(dataSetCentroidsId);
			H5.H5Dclose(dataSetMasksId);
			H5.H5Sclose(spaceCentroidsId);
			H5.H5Sclose(spaceMasksId);
			H5.H5Fclose(fileId);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private DialogOutput showSelectionDialog(String[] stacks) {


		GenericDialog gd = new GenericDialog("Extract ROIs to .h5");
		gd.addStringField("Id of the experiment:", this.DEFAULT_EXP_NAME, 20);
//		gd.addMessage("Extract patterns from:");
//		boolean[] defaultSelection =  new boolean[stacks.length];
//		if (stacks.length > 0) {
//			defaultSelection[0] = true;
//		}
//		gd.addCheckboxGroup(1, stacks.length, stacks, defaultSelection);
		gd.showDialog();
		if (gd.wasCanceled())
			return null;

		String experimentId = gd.getNextString();
		List<String> getSelectedStacksIDs = new LinkedList<>();
//		Vector<Checkbox> checkboxes = gd.getCheckboxes();
//		for(int i = 0; i < checkboxes.size(); i ++) {
//			if (checkboxes.elementAt(i).getState()) {
//				getSelectedStacksIDs.add(stacks[i]);
//			}
//		}

		return new DialogOutput(experimentId, getSelectedStacksIDs);
	}

	private void plotSignals(String stackId, double[][] patterns){
		if (patterns.length == 0) {
			return;
		}
		double xVector[] = new double[patterns[0].length];
		for (int i = 0; i < patterns[0].length; i++) {
			xVector[i] = i;
		}
		for (int i = 0; i < patterns.length; i++) {
			Plot plot = new Plot(stackId + ", Cell Signal " + (i + 1), "time", "luminescence", xVector, patterns[i]);
			plot.show();
		}
	}


	//-------------------------------------------------------//
	//						DEBUGGING						 //
	//-------------------------------------------------------//

	/**
	 * MAIN METHOD (FOR DEBUGGING).
	 *
	 * For debugging, it is convenient to have a method that starts ImageJ, loads
	 * an image and calls the plugin, e.g. after setting breakpoints.
	 *
	 * @param args unused
	 */
	public static void main(String[] args) {

		// set the plugins.dir property to make the plugin appear in the Plugins menu
		Class<?> clazz = Extract_ROIs_h5.class;
		String url = clazz.getResource("/" + clazz.getName().replace('.', '/') + ".class").toString();
		String pluginsDir = url.substring("file:".length(), url.length() - clazz.getName().length() - ".class".length());
		System.setProperty("plugins.dir", pluginsDir);

		// start ImageJ & open sample image
		new ImageJ();
		ImagePlus image1 = IJ.openImage("/home/fran_tr/AllOptical/Results/Blocks/M1/171213/1/block_1.tif");
		ImagePlus image0 = IJ.openImage("/home/fran_tr/AllOptical/Results/Blocks/M1/171214/1/block_0.tif");
		image1.show();
		image0.show();

		// run the plugin
		IJ.runPlugIn(clazz.getName(), "");
	}
}

class DialogOutput {
	private String experimentId;
	private List<String> selectedStacksIDs;

	public DialogOutput(String experimentId, List<String> selectedStacksIDs) {
		this.experimentId = experimentId;
		this.selectedStacksIDs = selectedStacksIDs;
	}

	public String getExperimentId() {
		return this.experimentId;
	}

	public List<String> getSelectedStacksIDs() {
		return this.selectedStacksIDs;
	}
}
