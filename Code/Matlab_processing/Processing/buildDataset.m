function buildDataset()

directionSelectivenessThreshold = 0.7;
orientationSelectivenessThreshold = 0.7;
qualityIndexThreshold = 0.58;

% load each trace for each experiment
experimentsPath = strcat(projectPath(), '/Experiments/');
relativeFolderPath = '/traces/';
experiments = dir(experimentsPath);

eulerResponsesMatrix = [];
cellCount = 0;
dsCount = 0;
osCount = 0;
for iExperiment = 3 : length(experiments) % exclude current (1) and parent (2) directories
	experimentFolder = experiments(iExperiment).name;
    expFolder = strcat(experimentsPath, experimentFolder, relativeFolderPath);
    cd(expFolder);
    
	try
        load('eulerResponses.mat', 'eulerAvgResponse', 'qualityIndex');    
        load('dirSelectivity.mat', 'dsK', 'osK');

        [nTraces, ~] = size(eulerAvgResponse);
        for iTraces = 1:nTraces
            if qualityIndex(iTraces) > qualityIndexThreshold
               if dsK(iTraces) > directionSelectivenessThreshold
                   dsCount = dsCount + 1;
                   dsLabels(dsCount).experiment = experimentFolder;
                   dsLabels(dsCount).nCell = iTraces;
               elseif osK(iTraces) > orientationSelectivenessThreshold
                   osCount = osCount + 1;
                   osLabels(osCount).experiment = experimentFolder;
                   osLabels(osCount).nCell = iTraces;
               else
                   cellCount = cellCount + 1;
                   eulerResponsesMatrix(cellCount, :) = eulerAvgResponse(iTraces, :);
                   cellsLabels(cellCount).experiment = experimentFolder;
                   cellsLabels(cellCount).nCell = iTraces;
               end
            end
        end
    catch
        fprintf('WARNING: traces for experiment %s missing or incomplete.\n they will not be included in the DATASET\n', experimentFolder);
    end
end

cd(strcat(projectPath(), '/Dataset'));

save('dataSetMatrix.mat', 'eulerResponsesMatrix', 'cellsLabels', 'dsLabels', 'osLabels');


