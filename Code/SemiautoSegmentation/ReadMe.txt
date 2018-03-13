
Export of the ROIs
==================

Setting up the code
-------------------

Before setting up the code, you need to copy tiff_tools.py and the Suite2P and MatlabGUI folders into a directory not sync with the main Owncloud: since you need to edit these files, you want to work with your local copy. Once this is done, you need to edit the file Suite/master_file.m on Line 7 and 15 to tell where are Suite2P/OASIS installed on your particular machine. 

Running the code
----------------

Open ipython, and simply import the tiff_tools functions

    >> ipython
    >> %run tiff_tools.py



The Experiment object
---------------------

In this script tiff_tools.py, you can create Experiment object such that you can play with all the recorded files and export ROIs using Suite2P.
To do so, do::
    
    >> ipython
    >> %run tiff_tools.py
    >> exp = Experiment('171815')


An experiment should be a folder where you have a lot of Tiffs files, and a CSV file describing everything (see below). Usually, there is one folder per day of experiment.

Parsing the CSV File
~~~~~~~~~~~~~~~~~~~~~

The information about the experiment are gather from the csv file in the folder of the data. The csv must have (at least) columns named
    - Filename
    - FrameRate
    - Comments
    - Stimulation Description
    - Group
    - ForRoi

Additional columns can be added, they will be ignored at the moment, but could be used if needed.


Accessing data structure
~~~~~~~~~~~~~~~~~~~~~~~~

The experiment object that you just created has several attributes, inherited from the CSV file

    >> exp.images[0].show()

will for example show you the first static image of the experiment. To know more about it, again, images are object with attributes

    >> exp.images[0].filename

The Experiment object has two main groups of data:
    - images (static images, where there is no FrameRate in the CSV file)
    - dynamic recordings

The recordings are automatically sorted into 2 groups:
    - holo
    - led

In fact, if in the Comments (or FileName) section of the CSV the pattern "holo" is present, the code will assume that this recordings belongs to the holo section. Otherwise, this is a led one. Then, within these 2 groups, the exact pattern of the stim is used as a key to the dictionary, such that you can do

    >> exp.recordings['holo']['Holographic stimulation']

This will be the list of all experiments with the Comments. To display the first one, for example

    >> exp.recordings['holo']['Holographic stimulation'][0].show()


Tagging recordings for ROIs definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ALl the files that are marked with a yes in the ForRoi column of the CSV file will be used when exporting data for the ROI selection. Note that they should all have the same spatial resolution. If not, then the code should trigger errors

Automatic merging of several FOV
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If a large FOV is aquired in 4 sub FOV (4 corners), then the script can automatically merge everything, assuming that the Comments column says which square is which (square XX), and assuming that the Group column for these 4 recordings have the same integer.


Automatic resampling of images
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When exporting data for Suite2P, the code will automatically resample experiments such that everything has the same frequency



Exporting data for the pipeline
-------------------------------

To export the data for Suite2P and visualize the Results in the MATLAB GUI, you can use the launch_pipeline() command. By default, the command will export all tiffs selected for ROIs (based on ForRoi column in the CSV file) into a dedicated folder (resampling everything, and potentially removing
stimulation artefacts), then launch Suite2P, then the MATLAB GUI. Those 4 steps ['generate', 'suite_2p', 'gui_export', 'gui'] can be launched independantly if needed

    >> exp.launch_pipeline('/output_dir')

However, you can specify special parameters for Suite2P if you want to

    >> exp.launch_pipeline('/output_dir', params={'diameter' : 12, 'nSVDforROI' : 100})

Or even decide to only launch the export of the TIFF
    
    >> exp.launch_pipeline('/output_dir', steps=['generate'])

Note that in ipython, you can view the documentation of any function by using the syntax
    
    >> exp.launch_pipeline?


Setting an HD image as a background for the GUI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can even, if you want to use a fix HD image as a background for the GUI, set it for the whole experiment. To do so

    >> exp.set_hd_image('myimage.tif')

And then, when you will use the pipeline, if the option reference is set to True (default), then the GUI will use this image as a background picture to view the ROIs


Display images of the experiments
---------------------------------

To view images of all the experiment:

    >> exp.view_images()
    >> exp.view_images(save=True)

You can also view all the movies:

    >> exp.view_recordings()
    >> exp.view_recordings(save=True)

Note that you can display only some types of recordings::
    
    >> exp.view_recordings(recordings=['led', 'holo'])

Or even some particular sim (using the Stim name of the Comments section in the CSV file)

    >> exp.view_recordings(recordings=['led', 'holo'], stim='My Stim')





Structure of the data
---------------------

Each Folder corresponds to a day of experiment. 
I put inside all the files recorded and a table with a description for each file of what is inside. 
The Euler full field stimulation is the stimulation included in the vector intensity.mat. The moving bar stimulation is a bar moving in the FOV in eight different directions around the center. 
In the image "squares" there is a picture of the global FOV in red divided by the 4 squares where we perform the visual stimulation. I numbered each squares and this is coherent in the tables for each experiment

