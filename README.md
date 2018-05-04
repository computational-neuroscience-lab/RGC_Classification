# RGC Classification - DRAFT

This is a Matlab project to perform classification of Retinal Ganglion Cells based on Calcium Imaging and Visual Stimulation.

The program parses the calcium traces recorded from the observed cells during exposition to a known visual stimulus, and outputs a classification of each cell in accordance to its behavior.

Based on the work from [Euler et al.](https://www.nature.com/articles/nature16468)

- **Input:** 

  - .tiff videos showing the calcium response of the cells. (see *Inputs* section)

  - .hdf5 files encoding the position of the cells - ROIs - in the video.  (see *Inputs* section)

  - .mat tables encoding the properties of the visual stimuli to whom the cells have been exposed. (see *Visual Stimuli* section

    ​

- **Output:**

  - .mat tables summarizing the results (see *Results* section)

    ​

## Project Structure

for the code to function properly, the project should keep the following folder structure.

- All the source code is in the `Code` folder.
- The input files representing cell ROIs and calcium traces must be in the `Experiments/traces` folder (see  *Inputs* section).
- The results and all the outputs of the program are saved in the `Datasets` folder as .mat tables (see `Results` section).
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
│	└───traces
│   
└───VisualStimulations
```



## Inputs

### Experiments Folder Structure

```
Experiments/traces
└───Datasets
│
└───Experiments
```



### Calcium recordings

The .tiff videos showing the calcium responses of the cells to the visual stimuli must be saved as 

- `Experiments/[ExpID]/traces/EulerStim.tiff`
- `Experiments/[ExpID]/traces/MovingBars{_suffix}.tiff`



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

## Run the Code

## Outputs

## Plots