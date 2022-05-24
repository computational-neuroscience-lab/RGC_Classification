function [MapId, Centers] = loadROIs_from_h5(experimentFolder)

expPath = strcat(dataPath(), '/', experimentFolder, '/traces/');
MapId = hdf5read(strcat(expPath,'TracesData.h5'), '/masks');
Centers = hdf5read(strcat(expPath,'TracesData.h5'), '/centroids');
save(strcat(expPath,'block_roi.mat'), 'MapId', 'Centers');



