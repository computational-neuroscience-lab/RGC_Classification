function parseEulerResponses()

load(strcat(projectPath(), '/VisualStimulations/EulerStim.mat'));

% load each trace for each experiment
experimentPath = strcat(projectPath, '/Experiments/');
relativeFolderPath = '/traces/';
experiments = dir(experimentPath);

for iExperiment = 3 : length(experiments) % exclude current (1) and parent (2) directories
    experimentFolder = experiments(iExperiment).name;
    expFolder = strcat(experimentPath, experimentFolder, relativeFolderPath);
        
    fprintf(strcat('Parsing Euler Traces for #', experimentFolder, '...\n'));

    % export traces from the .h5 file
    tracesFile = strcat(expFolder, 'TracesData.h5');
    if exist(tracesFile, 'file') == 0
        error('traces for experiment %s are missing', experimentFolder);
    end
    traces = hdf5read(tracesFile, '/EulerStim/patterns');

    % we initialize a matrix representing the single responses of
    % each cell to each repetition of the stimulus
    nTimeSteps = length(eulerStim_resampled_single);
    [nTraces, nTimeStepsRaw] = size(traces);
    eulerResponses = zeros(nTraces, nTimeSteps, nRepetitions);
    eulerNormResponses = zeros(nTraces, nTimeSteps, nRepetitions);
    
    ts_stim = round(cumsum(stimTimeSequence) * freqImaging);
    ts_stim_init = ts_stim(1);
    ts_stim_end = ts_stim(end);
    
    dts_response = round(responseTimeSequence * freqImaging);
    dts_resp_init = dts_response(1);
    dts_resp_end = dts_response(end);
        
    % we initialize the reference values F0
    % representing the expected cell output at steady state.
    % we define f0 as the average response in the 5 seconds preceeding
    % the stimulus
    F0_dt = 5;
    F0_dts = round(F0_dt * freqCalciumImaging);
    F0_ts_end = ts_stim_init;
    F0_ts_init = F0_ts_end - F0_dts;  
    F0 = zeros(nTraces, nRepetitions);
        
    % I build these matrices just for debugging and plotting, not really needed
    F0_means_On_Trace = zeros(nTraces, nTimeStepsRaw);
    
    for iRep = 1 : nRepetitions
        eulerResponses(:, :, iRep) = traces(:, (ts_stim_end*(iRep-1) + ts_stim_init - dts_resp_init) : (ts_stim_end*iRep + dts_resp_end));

        % build F0 and normalize the euler Response
        F0_interval = (F0_ts_init + ts_stim_end*(iRep-1)):(F0_ts_end + ts_stim_end*(iRep-1));
        F0(:, iRep) = median(traces(:, F0_interval),2);
        eulerNormResponses(:, :, iRep) = (eulerResponses(:, :, iRep) - F0(:, iRep)) ./ F0(:, iRep);
        
        % I build these matrices just for debugging and plotting, not really needed
        for x = 1:nTraces
            F0_means_On_Trace(x, F0_interval) = F0(x, iRep);
        end
    end
    
    % Response Quality index, defined as variance in time over variance in repetitions
    avgResponses = mean(eulerNormResponses, 3);
    timeVar_of_avgResponse = var(avgResponses, 0, 2);
    timeVariance = var(eulerNormResponses, 0, 2);
    avgOverResponses_of_timeVariance = mean(timeVariance, 3);
    qualityIndexEuler = timeVar_of_avgResponse ./ avgOverResponses_of_timeVariance;
    
    % Clean from noise
    eulerFilteredResponses = zeros(nTraces, nTimeSteps, nRepetitions);
    stdResponses = std(eulerNormResponses, 0, 3);
    sigmaN = mean(stdResponses, 2) * 2;
    for iTrace = 1 : nTraces
        for iRep = 1 : nRepetitions
            eulerFilteredResponses(iTrace, :, iRep) = NLmeansfilter(eulerNormResponses(iTrace, :, iRep), 10, 5, sigmaN(iTrace));
        end
    end
    
    % Average among repetitions
    eulerAvgResponse = median(eulerFilteredResponses, 3);
    
    % Cut the step-only response
    ts_response = round(cumsum(responseTimeSequence * freqImaging));
    ts_step_init = ts_response(1);
    ts_step_end = ts_response(3);
    stepAvgResponse = eulerAvgResponse(:, ts_step_init:ts_step_end);
    
    % scale
    peak = max(abs(eulerAvgResponse), [], 2);
    eulerAvgResponse = eulerAvgResponse ./ peak;
    peakStep = max(abs(stepAvgResponse), [], 2);
    stepAvgResponse = stepAvgResponse ./ peakStep;
    
    % Classify On vs Off
    [isOn, isOff] = onOffCellTyping(median(eulerNormResponses, 3));
    
    save(strcat(expFolder, 'eulerResponses.mat'), 'eulerResponses', 'eulerNormResponses', 'eulerFilteredResponses', 'eulerAvgResponse', 'stepAvgResponse', 'qualityIndexEuler');    
    save(strcat(expFolder, 'f0.mat'), 'F0', 'F0_means_On_Trace');
    save(strcat(expFolder, 'onOffTyping.mat'), 'isOn', 'isOff');
end