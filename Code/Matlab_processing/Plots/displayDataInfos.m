
experimentsPath = strcat(projectPath(), '/Experiments/');
dataRelativePath = '/traces/TracesData.h5';
experiments = dir(experimentsPath);

EulerMatrix = [];
BarsMatrix = [];

for i = 3 : length(experiments) % exclude current(1) and parent (2) directories
    experimentFolder = experiments(i).name;
    dataPath = strcat(experimentsPath, experimentFolder, dataRelativePath);
        
    fprintf('Experiment #%d: %s\n', i-2, experimentFolder);
    
    try
        eulerStim = hdf5read(dataPath, '/EulerStim/patterns');
        [nCells, nFrames] = size(eulerStim);
        EulerMatrix = [EulerMatrix; eulerStim];
        fprintf('\tEulerStim traces: %d X %d\n', nCells, nFrames);
    catch
        fprintf('\tEulerStim traces: NOT AVAILABLE\n');
    end
    
    try
        movingBars = hdf5read(dataPath, '/MovingBars/patterns');
        [nCells, nFrames] = size(movingBars);
        BarsMatrix = [BarsMatrix; movingBars];
        fprintf('\tMovingBars traces: %d X %d\n\n', nCells, nFrames);
    catch
        fprintf('\tMovingBars traces: NOT AVAILABLE\n\n');
    end    
end

[nBarsCells, nFramesBars] = size(BarsMatrix);
[nTotalCells, nFramesEuler] = size(EulerMatrix);
fprintf('\nTotal number of available cells: %d', nTotalCells);
fprintf('\nTotal number of available cells (moving bars): %d\n', nBarsCells);

