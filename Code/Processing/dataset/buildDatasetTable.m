function buildDatasetTable(experimentsCells)
experimentPath = strcat(projectPath, '/Experiments/');

if ~exist('experimentsCells', 'var') 
    % load each trace for each experiment
    experimentsStruct = dir(experimentPath);
    experimentsCells = {experimentsStruct(3:end).name};
end

directionSelectivenessThreshold = 0.7;
orientationSelectivenessThreshold = 1.0;
qualityIndexEulerThreshold = 0.6;
qualityIndexBarsThreshold = 0.2;

% load each trace for each experiment
experimentsPath = strcat(projectPath(), '/Experiments/');
relativeFolderPath = '/traces/';
experiments = dir(experimentsPath);

tracesMat = [];
cellCount = 0;
cellsTable = {};
for experimentCell = experimentsCells(1:end) % exclude current (1) and parent (2) directories
    experimentFolder = cell2mat(experimentCell);
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
        load(strcat(expFolder, 'onOffTyping_Euler.mat'), 'isOff_Euler', 'isOn_Euler');
        
        qtEuler = qualityIndexEuler > qualityIndexEulerThreshold;
        
        eulerIsOff = double(isOff_Euler);
        eulerIsOn = double(isOn_Euler);
        eulerIsOff(not(qtEuler)) = NaN;
        eulerIsOn(not(qtEuler))  = NaN;
    catch
        fprintf('\tWARNING: traces for experiment %s missing or incomplete: they will not be included in the DATASET', experimentFolder);
        continue
    end
    
    try
        % load the Bars Data
        load(strcat(expFolder, 'barResponses.mat'), 'normBarTraces', 'qualityIndexBars');    
        load(strcat(expFolder, 'dirSelectivity.mat'), 'dsK', 'osK', 'dsAngle', 'osAngle', 'dirModules');
        load(strcat(expFolder, 'onOffTyping_Bars.mat'), 'isOn_Bars', 'isOff_Bars');

        qtBars = qualityIndexBars > qualityIndexBarsThreshold;  
        
        barsIsOff = double(isOff_Bars);
        barsIsOn = double(isOn_Bars);
        barsIsOff(not(qtBars)) = NaN;
        barsIsOn(not(qtBars))  = NaN;
        
        ds_num(qtBars) = double(dsK(qtBars) > directionSelectivenessThreshold);
        os_num(qtBars) = double(osK(qtBars) > orientationSelectivenessThreshold);
        ds_num(not(qtBars)) = NaN;
        os_num(not(qtBars))  = NaN;
        
    catch
        % if Bars Data is not available, replace with NaN.
        fprintf('\tWARNING: bars traces for experiment %s missing: they will be coded as NaN in the DATASET', experimentFolder);

        qualityIndexBars = NaN(length(qtEuler), 1);
        qtBars = NaN(length(qtEuler), 1);
        
        barsIsOff = NaN(length(qtEuler), 1);
        barsIsOn = NaN(length(qtEuler), 1);
        
        ds_num = NaN(length(qtEuler), 1);
        os_num = NaN(length(qtEuler), 1);
                
        dsK = NaN(length(qtEuler), 1);
        osK = NaN(length(qtEuler), 1);
        
        dsAngle = NaN(length(qtEuler), 1);
        osAngle = NaN(length(qtEuler), 1);
        
        dirModules = NaN(length(qtEuler), 8);

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
        
        cellsTable(cellCount).EulerON = eulerIsOn(iTraces);
        cellsTable(cellCount).EulerOFF = eulerIsOff(iTraces);
        
        cellsTable(cellCount).BarsON = barsIsOn(iTraces);
        cellsTable(cellCount).BarsOFF = barsIsOff(iTraces);
        
        cellsTable(cellCount).DS = ds_num(iTraces);
        cellsTable(cellCount).OS = os_num(iTraces);        
        
        cellsTable(cellCount).DS_K = dsK(iTraces);
        cellsTable(cellCount).OS_K = osK(iTraces);
                        
        cellsTable(cellCount).DS_angle = dsAngle(iTraces);
        cellsTable(cellCount).OS_angle = osAngle(iTraces);
        
        cellsTable(cellCount).DS_vector = dirModules(iTraces, :);

        tracesMat(cellCount, :) = eulerAvgResponse(iTraces,  :);
    end
end
fprintf('\n\n')
save(getDatasetMat(), 'tracesMat', 'cellsTable');


