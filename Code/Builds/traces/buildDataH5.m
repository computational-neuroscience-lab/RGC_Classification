function buildDataH5(experimentFolder)

experimentsPath = strcat(projectPath(), '/Experiments/');
relativeFolderPath = '/traces/';

expFolder = strcat(experimentsPath, experimentFolder, relativeFolderPath);

if exist(strcat(expFolder,'TracesData.h5'), 'file') == 0
    error('ROIs information missing!');
end

fprintf('building Traces for Experiment #%s\n', experimentFolder);
[MapId, Centers] = get_RoiMat_from_RoiH5(experimentFolder);
[MapId, Centers] = removeBadROIs(MapId, Centers);
save_RoiMat(MapId, Centers, experimentFolder);
build_RoiH5_from_RoiMat(MapId, Centers, experimentFolder);

generateTracesInH5(experimentFolder);



