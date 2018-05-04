function displayDataInfos()

experimentsPath = strcat(projectPath(), '/Experiments/');
dataRelativePath = '/traces/TracesData.h5';
roisMat = '/traces/block_roi.mat';
experiments = dir(experimentsPath);

eulerCells = 0;
barsCells = 0;

for i = 3 : length(experiments) % exclude current(1) and parent (2) directories
    experimentFolder = experiments(i).name;
    dataPath = strcat(experimentsPath, experimentFolder, dataRelativePath);
    roisMatPath = strcat(experimentsPath, experimentFolder, roisMat);
        
    fprintf('Experiment #%d: %s\n', i-2, experimentFolder);
    
    try
        masks = hdf5read(dataPath, '/masks');
        load(roisMatPath, 'MapId');
        
        nROIs = size(masks, 3);
        nMapIds = size(MapId, 3);

        fprintf('\tROIs: %d \n', nROIs);
        fprintf('\tMapIds: %d \n', nMapIds);
    catch
        fprintf('\tROIs: NOT AVAILABLE\n\n');
    end   
    
    try
        eulerStim = hdf5read(dataPath, '/EulerStim/patterns');
        [nCells, nFrames] = size(eulerStim);
        eulerCells = eulerCells + nCells;
        fprintf('\tEulerStim traces: %d X %d\n', nCells, nFrames);
    catch
        fprintf('\tEulerStim traces: NOT AVAILABLE\n');
    end
    
    try
        movingBars = hdf5read(dataPath, '/MovingBars/patterns');
        [nCells, nFrames] = size(movingBars);
        barsCells = barsCells + nCells;
        fprintf('\tMovingBars traces: %d X %d\n\n', nCells, nFrames);
    catch
        fprintf('\tMovingBars traces: NOT AVAILABLE\n\n');
    end    
end

fprintf('\nTotal number of available cells: %d', eulerCells);
fprintf('\nTotal number of available cells (moving bars): %d\n', barsCells);

