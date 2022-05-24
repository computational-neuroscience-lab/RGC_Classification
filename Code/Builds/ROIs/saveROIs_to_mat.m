function saveROIs_to_mat(MapId, Centers, experimentFolder)
expPath = strcat(dataPath(), '/', experimentFolder, '/traces/');
save(strcat(expPath, 'block_roi.mat'), 'MapId', 'Centers');



