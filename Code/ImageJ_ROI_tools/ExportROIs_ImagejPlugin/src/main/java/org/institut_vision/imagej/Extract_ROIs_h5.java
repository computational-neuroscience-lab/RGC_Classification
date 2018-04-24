package org.institut_vision.imagej;

import ij.*;
import ij.gui.GenericDialog;
import ij.plugin.filter.PlugInFilter;
import ij.process.ImageProcessor;
import ij.process.ByteProcessor;
import ij.gui.Roi;
import ij.gui.Overlay;
import ij.io.SaveDialog;

import java.awt.*;

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
			IJ.showMessage("ROIs - export to .H5", "a plugin to export ROIs to .h5 files");
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

		// Compute the cell masks:
		ImagePlus[] cellMasks = this.getCellMasks(overlay, width, height);

		// Compute the cell centers
		double[][] cellCentroids = this.getCellCentroids(overlay);

		// Save in the .h5 file
		SaveDialog saveDialog = new SaveDialog("Where do you want to save your data?", "TracesData", ".h5");
		String path = saveDialog.getDirectory();
		if (path != null) {
			String h5fileName = path + saveDialog.getFileName();
			this.exportDataH5(h5fileName, cellCentroids, cellMasks);

			GenericDialog gd = new GenericDialog("Extract ROIs to .h5");
			gd.addMessage("Data succesfully exported to " + h5fileName);
			gd.showDialog();
		}
	}


	//-------------------------------------------------------//
	//					PRIVATE FUNCTIONS					 //
	//-------------------------------------------------------//

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

	private void exportDataH5(String fileName, double[][] cellCentroids, ImagePlus[] cellMasks) {

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
		ImagePlus image1 = IJ.openImage("./test_img.tif");
		image1.show();

		// run the plugin
		IJ.runPlugIn(clazz.getName(), "");
	}
}
