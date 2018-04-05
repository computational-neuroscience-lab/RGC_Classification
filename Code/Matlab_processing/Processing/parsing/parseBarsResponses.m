function parseBarsResponses()

% load each trace for each experiment
experimentPath = strcat(projectPath, '/Experiments/');
relativeFolderPath = '/traces/';
experiments = dir(experimentPath);

for iExperiment = 3 : length(experiments) % exclude current (1) and parent (2) directories
    experimentFolder = experiments(iExperiment).name;
    expFolder = strcat(experimentPath, experimentFolder, relativeFolderPath);

    fprintf(strcat('Parsing Bars Traces for #', experimentFolder, '...'));

    try
        % export traces from the .h5 file
        tracesFile = strcat(expFolder, 'TracesData.h5');
        traces = hdf5read(tracesFile, '/MovingBars/patterns');
        subtype = h5readatt(tracesFile,'/MovingBars/patterns', 'subtype');

        % load other cell infos from previous computations
        load( strcat(expFolder, 'onOffTyping.mat'), 'isOff');

        % Load Stimulus Data
        if strcmp(subtype, '')
            stimulusMat = '/VisualStimulations/MovingBars.mat';
        else
            stimulusMat = strcat('/VisualStimulations/MovingBars_', subtype, '.mat');
        end

        load(strcat(projectPath(), stimulusMat));

        nDirections = length(directions);
        nBars = length(directionsSequence);
        nRepetitions = nBars / nDirections;
        dts_bar = durationSingleBar * freqCalciumImaging;

        % get the bars index mapping to sort the traces
        [~, dirMapping] = sort(directionsSequence);
        setOfRepMapping = reshape(dirMapping, nRepetitions, nDirections);
        setOfRepMapping = reshape(setOfRepMapping', 1, nDirections*nRepetitions);

        % if we do not have a steady interval to use as F0, we will use the mean F0 from the Euler Stim experiment.
        ts_init = init_delay * freqCalciumImaging;

        if init_delay < 8
            load( strcat(expFolder, 'f0.mat'), 'F0');
            avgF0 = mean(F0, 2);
        else
            % we initialize the reference values F0
            % representing the expected cell output at steady state.
            % we define f0 as the average response in the 5 seconds preceeding
            % the stimulus
            F0_dt = 5;
            F0_dts = round(F0_dt * freqCalciumImaging);
            F0_ts_end = ts_init;
            F0_ts_init = F0_ts_end - F0_dts;  
            avgF0 = median(traces(:, F0_ts_init:F0_ts_end),2);
        end
        normBarTraces = (traces - avgF0) ./ avgF0;

        % we split the trace in 48 time bins, corresponding to the 48 moving bars
        [nTraces, ~] = size(normBarTraces);
        barResponses = zeros(nTraces, round(dts_bar), nBars);
        
        offset_OFF_CELLS = round(timeOffset_OffCells * freqCalciumImaging);
        offset_ON_CELLS = round(timeOffset_OnCells * freqCalciumImaging);
            
        for iBar = 1:nBars
            % we apply different offsets for ON and OFF cells, as their
            % responses have different timings
            ts_OFF_init = ts_init + offset_OFF_CELLS + round((iBar - 1) * dts_bar +1);
            ts_OFF_end  = ts_OFF_init + round(dts_bar) - 1;

            ts_ON_init = ts_init + offset_ON_CELLS + round((iBar - 1) * dts_bar +1);
            ts_ON_end  = ts_ON_init + round(dts_bar) - 1;

            barResponses(isOff, :, iBar) = normBarTraces(isOff, ts_OFF_init : ts_OFF_end);
            barResponses(not(isOff), :, iBar) = normBarTraces(not(isOff), ts_ON_init : ts_ON_end);            
        end     

        % Response Quality index, defined as variance in time over variance in repetitions
        sorted = barResponses(:, :, setOfRepMapping);
        avgResponses = mean(sorted, 3);
        timeVar_of_avgResponse = var(avgResponses, 0, 2);
        timeVariance = var(sorted, 0, 2);
        avgOverResponses_of_timeVariance = mean(timeVariance, 3);
        qualityIndexBars = timeVar_of_avgResponse ./ avgOverResponses_of_timeVariance;

        % band pass filtering
        nSteps = round(dts_bar);
        nResponses = nRepetitions * nDirections;
        barFullResponsesFiltered = zeros(nTraces, nSteps*nResponses);        
        for iCell = 1:nTraces
            barFullResponsesFiltered(iCell, :) = filterTrace(barResponses(iCell, :), freqCalciumImaging);
        end
        barResponsesFiltered = reshape(barFullResponsesFiltered, [nTraces, nSteps, nResponses]);

        % Average among repetitions
        barResponsesSorted = barResponsesFiltered(:, :, dirMapping);
        barResponsesByDirections = reshape(barResponsesSorted, [nTraces, round(dts_bar), nRepetitions, nDirections]);
        avgBarResponses = squeeze(median(barResponsesByDirections, 3));
        peaks = max(max(abs(avgBarResponses), [], 2), [], 3);
        avgBarResponses = avgBarResponses ./ peaks;

        % compute direction selectivity
        [osK, osAngle, dsK, dsAngle, dirModules] = directionSelectivity(directions, avgBarResponses);

        save(strcat(expFolder, 'barResponses.mat'), 'normBarTraces', 'barResponses', 'barResponsesFiltered', 'barResponsesSorted',  'avgBarResponses', 'qualityIndexBars');
        save(strcat(expFolder, 'dirSelectivity.mat'), 'osK', 'osAngle', 'dsK', 'dsAngle', 'dirModules', 'directions');  
    catch
            fprintf('\tWARNING: traces unavailable or corrupted');
    end
    fprintf('\n');
end
fprintf('\n');