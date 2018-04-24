package org.institut_vision.imagej;

import ij.*;
import ij.gui.GenericDialog;
import ij.plugin.filter.PlugInFilter;
import ij.process.ImageProcessor;
import ij.process.ByteProcessor;
import ij.process.FloatProcessor;
import ij.io.OpenDialog;

import ij.plugin.frame.RoiManager;
import ij.gui.PolygonRoi;
import ij.gui.Roi;

import hdf.hdf5lib.H5;
import hdf.hdf5lib.HDF5Constants;

import java.util.List;
import java.util.LinkedList;


/**
 *  An ImageJ plugin to extract luminescent patterns from cell recordings.
 */
public class Import_ROIs_h5 implements PlugInFilter {

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
			IJ.showMessage("ROIs - import from .H5", "a plugin to import ROIs from .h5 files");
			return DONE;
		}
		return DOES_8G | DOES_16 | DOES_32 | DOES_RGB;
	}

	@Override
	public void run(ImageProcessor ip) {
		ImagePlus roiImage = IJ.getImage();

		if (roiImage == null) {
            IJ.showMessage("No image selected");
            return;
        }


        // Save in the .h5 file
        OpenDialog readDialog = new OpenDialog("Import ROIs from a .h5 file");
        String path = readDialog.getDirectory();

        if (path == null) {
            IJ.showMessage("Path not valid");
            return;
        }

        String h5fileName = path + readDialog.getFileName();
        double[][][] masks = this.importROIH5(h5fileName);

        if(masks == null) {
            IJ.showMessage("Impossible to load ROIs from file");
            return;
        }

        List<Roi> rois = new LinkedList<>();
        for (double[][] mask : masks) {

            int w = mask[0].length;
            int h = mask.length;
            ImageProcessor maskImgPr = new ByteProcessor(w,h);

            for (int x = 0; x < w; x++) {
                for (int y = 0; y < h; y++) {
                    if (mask[x][y] > 0)
                        maskImgPr.putPixel(x, y, 255);
                    else
                        maskImgPr.putPixel(x, y, 0);
                }
            }

            ContourTracer ct = new ContourTracer(maskImgPr);

            List<Contour> contours = ct.getOuterContours();
            for(Contour contour : contours) {
                rois.add(new PolygonRoi(contour.makePolygon(), Roi.POLYGON));
            }
        }

        // update screen view of the image
        RoiManager rm = RoiManager.getInstance();
        if (rm == null) {
            rm = new RoiManager();
        }

        for (Roi roi : rois) {
            rm.addRoi(roi);
        }

        rm.runCommand(roiImage, "Show All");

        GenericDialog gd = new GenericDialog("Extract ROIs to .h5");
        gd.addMessage(masks.length + " ROIs succesfully imported from " + h5fileName);
        gd.showDialog();
    }


	//-------------------------------------------------------//
	//					PRIVATE FUNCTIONS					 //
	//-------------------------------------------------------//

	private double[][][] importROIH5(String fileName) {

		int fileId = -1;
		int datasetId = -1;

		try {
			fileId = H5.H5Fopen(fileName, HDF5Constants.H5F_ACC_RDWR, HDF5Constants.H5P_DEFAULT);
			if (fileId >= 0) datasetId = H5.H5Dopen(fileId, "masks", HDF5Constants.H5P_DEFAULT);

            int spaceId = H5.H5Dget_space(datasetId);
			int ndims = H5.H5Sget_simple_extent_ndims(spaceId);
            long dims[] = new long[ndims];
			H5.H5Sget_simple_extent_dims(spaceId, dims, null);

			double[][][] masks = new double[(int) dims[0]][(int) dims[1]][(int) dims[2]];

			if (datasetId >= 0) {
				H5.H5Dread(	datasetId, HDF5Constants.H5T_IEEE_F64LE,
							HDF5Constants.H5S_ALL, HDF5Constants.H5S_ALL,
							HDF5Constants.H5P_DEFAULT, masks);
			}

			// close everything
			H5.H5Dclose(datasetId);
			H5.H5Fclose(fileId);

			return masks;

		} catch (Exception e) {
			e.printStackTrace();
			return null;
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
		Class<?> clazz = Import_ROIs_h5.class;
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
