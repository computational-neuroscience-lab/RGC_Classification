function printAllCellCards()
close all;

% load each trace for each experiment
experimentsPath = strcat(projectPath(), '/Experiments/');
relativeFolderPath = '/traces/';
experiments = dir(experimentsPath);

for iExperiment = 3 : length(experiments) % exclude current (1) and parent (2) directories
    experimentFolder = experiments(iExperiment).name;
    expTraces = strcat(experimentsPath, experimentFolder, relativeFolderPath, 'TracesData.h5');

    % export traces from the .h5 file
    if exist(expTraces, 'file') == 0
        error('traces for experiment %s are missing', experimentFolder);
    end
    centroids = hdf5read(expTraces, '/centroids');
    [nCells, ~] = size(centroids);
    for iCell = 1:nCells
        plotCell( experimentFolder, iCell);

        cd(strcat(projectPath(), '/CellCards/DatasetCells'));
        title = strcat('Exp', experimentFolder, '_Cell#', int2str(iCell));
        saveas(gcf, title,'png')
        close;
    end    
end
cd(strcat(projectPath(), '/Code/Matlab_processing'));
        