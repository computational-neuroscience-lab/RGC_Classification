# RGC Classification - DRAFT

This is a Matlab project to perform classification of Retinal Ganglion Cells based on Calcium Imaging and Visual Stimulation.

The program parses the calcium traces recorded from cells exposed to a known visual stimulus, and outputs a classification of each cell in accordance to its behavior.

Based on the work from [Euler et al.](https://www.nature.com/articles/nature16468)

- **Input:** 

  - .tiff videos showing the calcium response of the cells. (see *Inputs* section)

  - .hdf5 files encoding the position of the cells - ROIs - in the video.  (see *Inputs* section)

  - .mat tables encoding the properties of the visual stimuli to whom the cells have been exposed. (see *Visual Stimuli* section

    ​

- **Output:**

  - .mat tables summarizing the results (see *Outputs* section)



Author: Francesco Trapani



## Project Structure

for the code to function properly, the project should keep the following folder structure.

- All the source code is in the `Code` folder.
- The input files representing cell ROIs and calcium traces must be in the `Experiments/traces` folder (see  *Inputs* section).
- The results and all the outputs of the program are saved in the `Datasets` folder as .mat tables (see *Outputs* section).
- **The correct path of ** `project_root` **should be coded in the ** `Code/projectPath.m` **function**

```
[project_root]
│   README.md
│   RESULTSiNFO.md
│
└───Code
│   │   projectPath.m
│   │	...
│   
└───Datasets
│   
└───Experiments
│	└───[EXP_1]
│	└───[EXP_2]
│	...
│	└───[EXP_N]
│   
└───VisualStimulations
```



## Inputs

### Experiments Folder Structure

```
[project_root]/Experiments/[EXP_N]/traces
│	EulerStim.tiff
│	MovingBars{_suffix}.tiff
│	TracesData.h5
│	...

```

### Calcium recordings

The .tiff videos showing the calcium responses of the cells to the visual stimuli must be saved as 

- `Experiments/[ExpID]/traces/EulerStim.tiff`

- `Experiments/[ExpID]/traces/MovingBars{_suffix}.tiff`

  the suffix indicates which different subversion of the stimulus has been used. Depending on this suffix, different parameters are loaded to parse the calcium responses.



### TracesData.h5

The ROIs representing the cell must be saved as a H5 structure in `Experiments/[ExpID]/traces/TracesData.h5`. 

The H5 file must have the following structure:

```
HDF5 TracesData.h5 

Group '/' 
    Dataset 'centroids' 
        Size:  [nCells]x2
        Datatype:   H5T_IEEE_F64LE (double)
        
    Dataset 'masks' 
        Size:  [movie_width]x[movie_height]x[nCells]
        Datatype:   H5T_IEEE_F64LE (double)
        
```

Where `centroids` are the ROIs centroids and `masks` are binary masks representing the ROIs.

- Notice that this is exactly the structure of the .h5 file outputted by the ImageJ_ROIs_Tool plug-in. 
- The function `Code/Builds/ROIs/saveROIs_to_h5` is another option to build the TracesData.h5 files.




## Visual Stimuli

```
[project_root]/VisualStimulations
│	EulerStim.mat
│	MovingBars{_suffix1}.mat
│	MovingBars{_suffix2}.mat
│	...
│	MovingBars{_suffixN}.mat
```
For each stimuli type used in the experiments, a corresponding .mat file with the correct values for each stimulus parameter must be present in the `Visual Stimuli` folder. 
The parameters in the .mat files encode information such as duration of each sequence in the stimulus, number of repetitions, initial offset, etc. 



## Run the Code

The code is divided in three sections: *Build*, *Process*, *Plot*.

1. **Build:** code to extract and save the calcium traces. 

   - `main.m` : for each experiment, extracts all the ROI traces from the .tiff videos and saves it in the `TracesData.h5` file.
   - `displayDataInfos`: displays which data is stored in the `TracesData.h5` file for each experiment.
   - `saveROIs_to_h5`:  saves the ROIs into a `TracesData.h5` file.

2. **Process:** 

   - `main.m`: performs all the processing pipeline, taking the calcium traces as input and generating the classification tables as output.


   - Parsing: code for normalizing and parsing all the neural responses.
   - Datasets: code for generating a unique dataset table with all the neural responses. Different datasets can be created and saved at the same time. For each dataset, a mat file `Datasets/[datasetName].mat` is generated.
   - Clustering: performs the clustering on the currently active dataset. The results are saved in the `Datasets/[datasetName].mat` file, where `datasetName` is the currently active dataset.

3. **Plot:** all the code to plot the data. 

   - `plotCell`: plots all the information related to a given cell.
   - `plotLeafClassesAvg`: plots the most specific subclasses of a given class. Empty string `""` represents the broadest class (that is, the whole dataset). Subclasses are represented with the average response.
   - `plotLeafClusters`: plots the most specific subclasses of a given class. Empty string `""` represents the broadest class (that is, the whole dataset). Subclasses are displayed as clusters in the 3 principal components space.
   - ...



## Outputs

All the results of the classification are saved in the `Datasets/[datasetName].mat` file, where `datasetName` is the currently active dataset.

The class labels are assigned in a tree structure, from the broadest to the most specific classes.

The encoding of the results is explained in `RESULTSiNFO.md`

