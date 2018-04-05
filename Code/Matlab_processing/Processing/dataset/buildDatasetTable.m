function buildDatasetTable()

directionSelectivenessThreshold = 0.7;
orientationSelectivenessThreshold = 1.0;
qualityIndexEulerThreshold = 0.6;
qualityIndexBarsThreshold = 0.2;

% load each trace for each experiment
experimentsPath = strcat(projectPath(), '/Experiments/');
relativeFolderPath = '/traces/';
experiments = dir(experimentsPath);

eulerResponsesMatrix = [];
stepResponsesMatrix = [];
cellCount = 0;
cellsLabels = {};
for iExperiment = 3 : length(experiments) % exclude current (1) and parent (2) directories
	experimentFolder = experiments(iExperiment).name;
    expFolder = strcat(experimentsPath, experimentFolder, relativeFolderPath);
    
    fprintf(strcat('\nIncluding experiment #', experimentFolder, ' in the dataset...'));

    try
        % load Euler Responses
        load(strcat(expFolder, 'eulerResponses.mat'), 'eulerAvgResponse', 'stepAvgResponse', 'qualityIndexEuler');    
        load(strcat(expFolder, 'onOffTyping.mat'), 'isOff', 'isOn');
        
        qtEuler = qualityIndexEuler > qualityIndexEulerThreshold;
        isOff_num = double(isOff);
        isOn_num = double(isOn);

        isOff_num(not(qtEuler)) = NaN;
        isOn_num(not(qtEuler))  = NaN;

        try
            % load the Bars Data
            load(strcat(expFolder, 'barResponses.mat'), 'qualityIndexBars');    
            load(strcat(expFolder, 'dirSelectivity.mat'), 'dsK', 'osK');
            
            qtBars = qualityIndexBars > qualityIndexBarsThreshold;  

            ds_num(qtBars) = double(dsK(qtBars) > directionSelectivenessThreshold);
            os_num(qtBars) = double(osK(qtBars) > orientationSelectivenessThreshold);
            ds_num(not(qtBars)) = NaN;
            os_num(not(qtBars))  = NaN;
            
        catch
            % if Bars Data is not available, replace with NaN.
            fprintf('\tWARNING: bars traces for experiment %s missing: they will be coded as NaN in the DATASET', experimentFolder);

            qtBars = NaN(length(qtEuler), 1);
            ds_num = NaN(length(qtEuler), 1);
            os_num = NaN(length(qtEuler), 1);
        end

        [nTraces, ~] = size(eulerAvgResponse);
        for iTraces = 1:nTraces
            cellCount = cellCount + 1;
            
            cellsLabels(cellCount).experiment = string(experimentFolder);
            cellsLabels(cellCount).N = iTraces;
            cellsLabels(cellCount).eulerQT = qtEuler(iTraces);
            cellsLabels(cellCount).barsQT = qtBars(iTraces);
            cellsLabels(cellCount).ON = isOn_num(iTraces);
            cellsLabels(cellCount).OFF = isOff_num(iTraces);
            cellsLabels(cellCount).DS = ds_num(iTraces);
            cellsLabels(cellCount).OS = os_num(iTraces);
            
            eulerResponsesMatrix(cellCount, :) = eulerAvgResponse(iTraces,  :);
            stepResponsesMatrix(cellCount, :) = stepAvgResponse(iTraces,  :);
        end
    catch
        fprintf('\tWARNING: traces for experiment %s missing or incomplete: they will not be included in the DATASET', experimentFolder);
    end
end
fprintf('\n\n')
save(getDatasetMat(), 'eulerResponsesMatrix', 'stepResponsesMatrix', 'cellsLabels');


