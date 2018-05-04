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
cellsTable = {};
for iExperiment = 3 : length(experiments) % exclude current (1) and parent (2) directories
	experimentFolder = experiments(iExperiment).name;
    expFolder = strcat(experimentsPath, experimentFolder, relativeFolderPath);
    
    fprintf(strcat('\nIncluding experiment #', experimentFolder, ' in the dataset...'));
    
    % load raw data
    try
        rawDataFile = strcat(expFolder, 'TracesData.h5');
        traces = hdf5read(rawDataFile, '/EulerStim/patterns');
        rois = hdf5read(rawDataFile, '/masks');
        
        avgFluorescence = mean(traces, 2);
        somaSize = squeeze(sum(sum(logical(rois))));  
    catch
        error(strcat("NO raw data available for experiment ", experimentFolder))
    end


    try
        % load Euler Responses
        load(strcat(expFolder, 'eulerResponses.mat'), 'eulerAvgResponse', 'eulerAvgResponse', 'stepAvgResponse', 'qualityIndexEuler');    
        load(strcat(expFolder, 'onOffTyping.mat'), 'isOff', 'isOn');
        
        qtEuler = qualityIndexEuler > qualityIndexEulerThreshold;
        isOff_num = double(isOff);
        isOn_num = double(isOn);

        isOff_num(not(qtEuler)) = NaN;
        isOn_num(not(qtEuler))  = NaN;
    catch
        fprintf('\tWARNING: traces for experiment %s missing or incomplete: they will not be included in the DATASET', experimentFolder);
        continue
    end
    
    try
        % load the Bars Data
        load(strcat(expFolder, 'barResponses.mat'), 'qualityIndexBars');    
        load(strcat(expFolder, 'dirSelectivity.mat'), 'dsK', 'osK', 'dsAngle', 'osAngle');

        qtBars = qualityIndexBars > qualityIndexBarsThreshold;  

        ds_num(qtBars) = double(dsK(qtBars) > directionSelectivenessThreshold);
        os_num(qtBars) = double(osK(qtBars) > orientationSelectivenessThreshold);
        ds_num(not(qtBars)) = NaN;
        os_num(not(qtBars))  = NaN;

    catch
        % if Bars Data is not available, replace with NaN.
        fprintf('\tWARNING: bars traces for experiment %s missing: they will be coded as NaN in the DATASET', experimentFolder);

        qualityIndexBars = NaN(length(qtEuler), 1);
        qtBars = NaN(length(qtEuler), 1);
        
        ds_num = NaN(length(qtEuler), 1);
        os_num = NaN(length(qtEuler), 1);
                
        dsK = NaN(length(qtEuler), 1);
        osK = NaN(length(qtEuler), 1);
        
        dsAngle = NaN(length(qtEuler), 1);
        osAngle = NaN(length(qtEuler), 1);
    end

    [nTraces, ~] = size(eulerAvgResponse);
    for iTraces = 1:nTraces
        cellCount = cellCount + 1;

        cellsTable(cellCount).experiment = string(experimentFolder);
        cellsTable(cellCount).N = iTraces;
        
        cellsTable(cellCount).soma = somaSize(iTraces);
        cellsTable(cellCount).fluo = avgFluorescence(iTraces);
        
        cellsTable(cellCount).eulerQT = qtEuler(iTraces);
        cellsTable(cellCount).barsQT = qtBars(iTraces);
        
        cellsTable(cellCount).eulerQI = qualityIndexEuler(iTraces);
        cellsTable(cellCount).barsQI = qualityIndexBars(iTraces);
        
        cellsTable(cellCount).ON = isOn_num(iTraces);
        cellsTable(cellCount).OFF = isOff_num(iTraces);
        
        cellsTable(cellCount).DS = ds_num(iTraces);
        cellsTable(cellCount).OS = os_num(iTraces);        
        
        cellsTable(cellCount).DS_K = dsK(iTraces);
        cellsTable(cellCount).OS_K = osK(iTraces);
                        
        cellsTable(cellCount).DS_angle = dsAngle(iTraces);
        cellsTable(cellCount).OS_angle = osAngle(iTraces);

        eulerResponsesMatrix(cellCount, :) = eulerAvgResponse(iTraces,  :);
        stepResponsesMatrix(cellCount, :) = stepAvgResponse(iTraces,  :);
    end
end
fprintf('\n\n')
save(getDatasetMat(), 'eulerResponsesMatrix', 'stepResponsesMatrix', 'cellsTable');


