
experimentsPath = strcat(projectPath(), '/Experiments/');
relativeFolderPath = '/traces/';
experiments = dir(experimentsPath);

fprintf('Traces will be generated for %d experiments\n\n', length(experiments) - 2);
for i = 8 : length(experiments) % exclude current(1) and parent (2) directories
    experimentFolder = experiments(i).name;
    expFolder = strcat(experimentsPath, experimentFolder, relativeFolderPath);
    
    cd(expFolder);
    if exist('TracesData.h5', 'file') == 0 && exist('block_roi.mat', 'file') == 0
        error('ROIs information missing!');
    end
    
    if exist('block_roi.mat', 'file') == 0
        MapId = hdf5read('TracesData.h5', '/masks');
        Centers = hdf5read('TracesData.h5', '/centroids');
        save('block_roi.mat', 'MapId', 'Centers')
    end
    
    fprintf('building Experiment #%d: %s\n', i-2, experimentFolder);
    delete('TracesData.h5');
    buildH5
end

fprintf('\n\n\nOperation Completed\n\n');
displayDataInfos;


