function [MapId, Centers] = get_RoiMat_from_RoiH5(experimentFolder)

experimentsPath = strcat(projectPath(), '/Experiments/');
relativeFolderPath = '/traces/';
expFolder = strcat(experimentsPath, experimentFolder, relativeFolderPath);
    
MapId = hdf5read(strcat(expFolder,'TracesData.h5'), '/masks');
Centers = hdf5read(strcat(expFolder,'TracesData.h5'), '/centroids');
save(strcat(expFolder,'block_roi.mat'), 'MapId', 'Centers');



