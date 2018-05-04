function saveROIs_to_mat(MapId, Centers, experimentFolder)

expPath = strcat(projectPath(), '/Experiments/', experimentFolder, '/traces/');
save(strcat(expPath,'block_roi.mat'), 'MapId', 'Centers');



