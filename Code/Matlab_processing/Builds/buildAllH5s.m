function buildAllH5s()

experimentsPath = strcat(projectPath(), '/Experiments/');
relativeFolderPath = '/traces/';
experiments = dir(experimentsPath);

fprintf('Traces will be generated for %d experiments\n\n', length(experiments) - 2);
for i = 3 : length(experiments) % exclude current(1) and parent (2) directories
    experimentFolder = experiments(i).name;
    expFolder = strcat(experimentsPath, experimentFolder, relativeFolderPath);
    
    if exist(strcat(expFolder,'TracesData.h5'), 'file') == 0 && exist(strcat(expFolder,'block_roi.mat'), 'file') == 0
        error('ROIs information missing!');
    end
    
    if exist(strcat(expFolder,'block_roi.mat'), 'file') == 0
        MapId = hdf5read(strcat(expFolder,'TracesData.h5'), '/masks');
        Centers = hdf5read(strcat(expFolder,'TracesData.h5'), '/centroids');
        save(strcat(expFolder,'block_roi.mat'), 'MapId', 'Centers')
    end
    
    fprintf('building Experiment #%d: %s\n', i-2, experimentFolder);
    delete(strcat(expFolder,'TracesData.h5'));
    buildH5(experimentFolder);
end

fprintf('\n\n\nOperation Completed\n\n');
displayDataInfos;


