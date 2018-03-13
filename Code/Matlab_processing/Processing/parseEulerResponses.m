function parseEulerResponses()

% Load Experimental Parameters and information about the stimulus
load(strcat(projectPath(), '/VisualStimulations/EulerStim.mat'), 'eulerStim');
load(strcat(projectPath(), '/VisualStimulations/EulerExperimentalParameters.mat'));

% Resample Stimuli
eulerTimeV = 0 : 1 / eulerStimFreq : (eulerStimDuration*eulerNumRepetitions - 1 / eulerStimFreq);
eulerTimeSeries = timeseries(eulerStim, eulerTimeV);

resampleEulerTimeV = 0 : 1 / eulerImagingFreq : (eulerStimDuration*eulerNumRepetitions - 1 / eulerImagingFreq);
resampledEulerTimeSeries = resample(eulerTimeSeries, resampleEulerTimeV);
resampledEulerStim = squeeze(resampledEulerTimeSeries.data);

% We want to look at the at the stimulus response including
% [eulerDt] secs before and after the actual stimulus.
stimStartOnTrace = round(eulerHighStimTime * eulerImagingFreq);
stimLengthOnTrace = round(eulerStimDuration * eulerImagingFreq);

dtstep = eulerDt * eulerImagingFreq;
singleEulerStim = resampledEulerStim(stimStartOnTrace - dtstep : stimLengthOnTrace + dtstep);

save(strcat(projectPath(), '/VisualStimulations/EulerStim.mat'), 'eulerStim', 'resampledEulerStim', 'singleEulerStim');

% load each trace for each experiment
experimentPath = strcat(projectPath, '/Experiments/');
relativeFolderPath = '/traces/';
experiments = dir(experimentPath);

for iExperiment = 3 : length(experiments) % exclude current (1) and parent (2) directories
    experimentFolder = experiments(iExperiment).name;
    expFolder = strcat(experimentPath, experimentFolder, relativeFolderPath);
    cd(expFolder);
        
    % export traces from the .h5 file
    if exist('TracesData.h5', 'file') == 0
        error('traces for experiment %s are missing', experimentFolder);
    end
    traces = hdf5read('TracesData.h5', '/EulerStim/patterns');
    
    % we initialize a matrix representing the single responses of
    % each cell to each repetition of the stimulus
    [nStepsSingleResponse, ~] = size(singleEulerStim);
    [nTraces, nTimeStepsRaw] = size(traces);
    eulerResponses = zeros(nTraces, nStepsSingleResponse, eulerNumRepetitions);
    eulerNormResponses = zeros(nTraces, nStepsSingleResponse, eulerNumRepetitions);
        
    % we initialize the reference values F0
    % representing the expected cell output at steady state.
    % we define f0 as the average response in the 10 seconds preceeding
    % the stimulus
    F0_dt = 5;
    nF0Steps = round(F0_dt * eulerImagingFreq);
    F0_end = stimStartOnTrace;
    F0_start = F0_end - nF0Steps;  
    F0 = zeros(nTraces, eulerNumRepetitions);
        
    % I build these matrices just for debugging and plotting, not really needed
    F0_intervals_On_Trace = zeros(nTraces, nTimeStepsRaw);
    F0_means_On_Trace = zeros(nTraces, nTimeStepsRaw);
    
    for iRep = 1 : eulerNumRepetitions
        eulerResponses(:, :, iRep) = traces(:, (stimLengthOnTrace*(iRep-1) + stimStartOnTrace - dtstep) : (stimLengthOnTrace*iRep + dtstep));

        % build F0 and normalize the euler Response
        F0_interval = (F0_start + stimLengthOnTrace * (iRep-1)):(F0_end + stimLengthOnTrace * (iRep-1));
        F0(:, iRep) = median(traces(:, F0_interval),2);
        eulerNormResponses(:, :, iRep) = (eulerResponses(:, :, iRep) - F0(:, iRep)) ./ F0(:, iRep);
        
        % I build these matrices just for debugging and plotting, not really needed
        F0_intervals_On_Trace(:, F0_interval) = traces(:, F0_interval);
        for x = 1:nTraces
            F0_means_On_Trace(x, F0_interval) = F0(x, iRep);
        end
    end
    
    % Response Quality index, defined as variance in time over variance in repetitions
    avgResponses = mean(eulerNormResponses, 3);
    timeVar_of_avgResponse = var(avgResponses, 0, 2);
    timeVariance = var(eulerNormResponses, 0, 2);
    avgOverResponses_of_timeVariance = mean(timeVariance, 3);
    qualityIndex = timeVar_of_avgResponse ./ avgOverResponses_of_timeVariance;
    
    % Clean from noise
    eulerFilteredResponses = zeros(nTraces, nStepsSingleResponse, eulerNumRepetitions);
    stdResponses = std(eulerNormResponses, 0, 3);
    sigmaN = mean(stdResponses, 2) * 2;
    for iTrace = 1 : nTraces
        for iRep = 1 : eulerNumRepetitions
            eulerFilteredResponses(iTrace, :, iRep) = NLmeansfilter(eulerNormResponses(iTrace, :, iRep), 10, 5, sigmaN(iTrace));
        end
    end
    
    % Average among repetitions
    eulerAvgResponse = median(eulerFilteredResponses, 3);    
    peak = max(abs(eulerAvgResponse), [], 2);
    eulerAvgResponse = eulerAvgResponse ./ peak;
    
    % Classify On vs Off
    isOff = onOffCellTyping(eulerAvgResponse);
    
    save('eulerResponses.mat', 'eulerResponses', 'eulerNormResponses', 'eulerFilteredResponses', 'eulerAvgResponse', 'qualityIndex');    
    save('f0.mat', 'F0', 'F0_intervals_On_Trace', 'F0_means_On_Trace');
    save('onOffTyping.mat', 'isOff');

end
cd(strcat(projectPath(), '/Code/Matlab_processing/Processing'));