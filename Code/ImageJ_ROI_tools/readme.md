Imagej ROI Tools
================

Utilities for selecting and exporting cell ROIs in *Imagej*

ROI Selection Macro
------------------

A simple macro that automatically generates, arranges, scales and synchronizes:
1. The original stack
2. The Z-blurred stack (to mitigate noise over slices)
3. The standard deviation of **1**
4. The standard deviation of **2**
5. Plot of the ROI trace in the Original Stack
6. Plot of ROI trace in the Z-Blurred Stack
7. Synchronization Panel

 Selected ROIs will be shown at the same time on each stack,
 and the corresponding trace plots are updated in real time.



#### Temporary Installation

From the *ImageJ* main menu:

``
Plugins >> Macros >> Install
``

and select the *ROIs_tool_Macro.ijm* file.

#### Permanent Installation

Append the content of the *ROIs_tool_Macro.ijm* file at the bottom of this text file:
 
``
{path_to_the_Imagej_Folder}/macros/StartupMacros.fiji.ijm
``


#### How to use

select a stack and press **[q]**



Export ROIs Plugin
------------------

A simple Plugin that allows you to export an overlay of ROIs from ImageJ into a structured [*hdf5*](https://fr.mathworks.com/help/matlab/hdf5-files.html) file



### Prerequisites
Make sure that ImageJ has access to the HDF5 Java library. In order to do so:
1. Download and build the [HDF Java Library](https://support.hdfgroup.org/products/java/release/download.html)
2. Copy the *jarhdf5-3.3.2.jar*  Java library into: `{path_to_the_Imagej_Folder}/jars`
3. Copy the following native C libraries :
    * *libjhdf5.so*
    * *libjhdf5.so.3.3.2* (or whatever versioning you have)
    * *libjhdf5.so.settings*
    
    into the Imagej *java.library.path* (for my linux system that was `{path_to_the_Imagej_Folder}/lib/linux64`)
        



### Installation

Copy the *Export_ROIs_h5-1.0.jar* file into:
 
``
{path_to_the_Imagej_Folder}/plugins
``

### How to use

Select the stack containing the ROIs you want to export.
Then from the *ImageJ* main menu:

``
Image >> Export ROIs to .h5
``


## Authors

* **Francesco Trapani**