function save_RoiMat(MapId, Centers, experimentFolder)

experimentsPath = strcat(projectPath(), '/Experiments/');
relativeFolderPath = '/traces/';
expFolder = strcat(experimentsPath, experimentFolder, relativeFolderPath);

save(strcat(expFolder,'block_roi.mat'), 'MapId', 'Centers');



