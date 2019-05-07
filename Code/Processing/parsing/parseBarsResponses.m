function parseBarsResponses(experiments)

% load each trace for each experiment
experimentPath = strcat(dataPath(), '/');
relativeFolderPath = '/traces/';

if ~exist('experimentsCells', 'var') 
    % load each trace for each experiment
    experimentsStruct = dir(experimentPath);
    experiments = {experimentsStruct(3:end).name}; % exclude current (1) and parent (2) directories
end

for experiment = experiments(1:end) 
    experimentFolder = cell2mat(experiment);
    expPath = strcat(experimentPath, experimentFolder, relativeFolderPath);
    fprintf(strcat('Parsing Bars Traces for #', experimentFolder, '...'));
    
    try
        % export traces from the .h5 file
        tracesFile = strcat(expPath, 'TracesData.h5');
        traces = hdf5read(tracesFile, '/MovingBars/patterns');

        % Load Stimulus Data
        load(getBarsStimulus(experimentFolder))
    catch
        fprintf('\tWARNING: traces unavailable or corrupted\n');
        continue;
    end

    nDirections = length(directions);
    nBars = length(directionsSequence);
    nRepetitions = nBars / nDirections;
    dts_bar = durationSingleBar * freqCalciumImaging;
    nTraces = size(traces, 1);
    
    offset_OFF = round(timeOffset_OffCells * freqCalciumImaging);
    offset_ON = round(timeOffset_OnCells * freqCalciumImaging);

    % get the bars index mapping to sort the traces
    [~, dirMapping] = sort(directionsSequence);
    setOfRepMapping = reshape(dirMapping, nRepetitions, nDirections);
    setOfRepMapping = reshape(setOfRepMapping', 1, nDirections*nRepetitions);

    % if we do not have a steady interval to use as F0, we will use the mean F0 from the Euler Stim experiment.
    ts_init = init_delay * freqCalciumImaging;

    if init_delay < 8
        load( strcat(expPath, 'f0.mat'), 'F0');
        avgF0 = mean(F0, 2);
    else
        % we initialize the reference values F0
        % representing the expected cell output at steady state.
        % we define f0 as the average response in the 5 seconds preceeding
        % the stimulus
        F0_dt = 5;
        F0_dts = round(F0_dt * freqCalciumImaging);
        F0_ts_end = round(ts_init);
        F0_ts_init = F0_ts_end - F0_dts;  
        avgF0 = median(traces(:, F0_ts_init:F0_ts_end),2);
    end
    normBarTraces = (traces - avgF0) ./ avgF0;
    
    % compute the On/Off typing respect to the bars response
    step_window = 20;
    barsResponses = zeros(nTraces, round(dts_bar) + step_window, nBars);
    for iBar = 1:nBars
        bar_init_ts = round(ts_init + (iBar - 1) * dts_bar +1);
        bar_end_ts = bar_init_ts + round(dts_bar) + step_window - 1;
        barsResponses(:, :, iBar) = normBarTraces(:, bar_init_ts: bar_end_ts);
    end 
    [isOn_Bars, isOff_Bars] = onOffCellTyping(median(barsResponses, 3), offset_ON, offset_OFF, step_window, step_window/4);

    % We split the trace in n time bins, corresponding to the n moving bars.
    % We apply different offsets for ON and OFF cells, as their responses 
    % have different timings. 
    barsResponsesAligned = zeros(nTraces, round(dts_bar), nBars);
    for iBar = 1:nBars
        bar_init_ts = round(ts_init + (iBar - 1) * dts_bar +1);
        bar_end_ts = bar_init_ts + round(dts_bar) - 1;

        ts_OFF_init = offset_OFF + bar_init_ts;
        ts_OFF_end  = offset_OFF + bar_end_ts;

        ts_ON_init = offset_ON + bar_init_ts;
        ts_ON_end  = offset_ON + bar_end_ts;
        
        barsResponsesAligned(isOn_Bars, :, iBar) = normBarTraces(isOn_Bars, ts_ON_init : ts_ON_end);  
        barsResponsesAligned(not(isOn_Bars), :, iBar) = normBarTraces(not(isOn_Bars), ts_OFF_init : ts_OFF_end);
    end     

    % Response Quality index, defined as variance in time over variance in repetitions
    sorted = barsResponsesAligned(:, :, setOfRepMapping);
    avgResponses = mean(sorted, 3);
    timeVar_of_avgResponse = var(avgResponses, 0, 2);
    timeVariance = var(sorted, 0, 2);
    avgOverResponses_of_timeVariance = mean(timeVariance, 3);
    qualityIndexBars = timeVar_of_avgResponse ./ avgOverResponses_of_timeVariance;

    % Average among repetitions
    barResponsesSortedAligned = barsResponsesAligned(:, :, dirMapping);
    barResponsesByDirectionsAligned = reshape(barResponsesSortedAligned, [nTraces, round(dts_bar), nRepetitions, nDirections]);
    avgBarResponsesAligned = squeeze(median(barResponsesByDirectionsAligned, 3));
    peaks = max(max(abs(avgBarResponsesAligned), [], 2), [], 3);
    avgBarResponsesAligned = avgBarResponsesAligned ./ peaks;
    
    barResponsesSorted = barsResponses(:, :, dirMapping);
    barResponsesByDirections = reshape(barResponsesSorted, [nTraces, round(dts_bar) + step_window, nRepetitions, nDirections]);
    avgBarResponsesNotNorm = squeeze(median(barResponsesByDirections, 3));
    peaksBars = max(max(abs(avgBarResponsesNotNorm), [], 2), [], 3);
    avgBarResponses = avgBarResponsesNotNorm ./ peaksBars;

    % compute direction selectivity
    [osK, osAngle, dsK, dsAngle, dirModules] = directionSelectivity(directions, avgBarResponsesAligned);

    save(strcat(expPath, 'barResponses.mat'), 'normBarTraces', 'barsResponses', 'barResponsesSorted', 'barsResponsesAligned', 'avgBarResponses', 'avgBarResponsesAligned', 'avgBarResponsesNotNorm',  'qualityIndexBars');
    save(strcat(expPath, 'dirSelectivity.mat'), 'osK', 'osAngle', 'dsK', 'dsAngle', 'dirModules', 'directions'); 
    save(strcat(expPath, 'onOffTyping_Bars.mat'), 'isOn_Bars', 'isOff_Bars');

    fprintf('\n');
end
fprintf('\n');