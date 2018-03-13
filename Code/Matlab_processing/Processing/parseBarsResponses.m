function parseBarsResponses()

% Load Experimental Parameters and information about the stimulus
load(strcat(projectPath(), '/VisualStimulations/BarsExperimentalParameters.mat'));

[~, nDirections] = size(barDirections);
nRepetitions = sum(barDirectionRepetitions(:) == 1); % assuming all the directions have the same number of repetitions
nBars = nDirections * nRepetitions;
nStepsBarResp = singleBarDuration * barsImagingFreq;

%get the bars index mapping to sort the traces
[~, dirMapping] = sort(barDirectionRepetitions);

% load each trace for each experiment
experimentPath = strcat(projectPath, '/Experiments/');
relativeFolderPath = '/traces/';
experiments = dir(experimentPath);

for iExperiment = 3 : length(experiments) % exclude current (1) and parent (2) directories
    experimentFolder = experiments(iExperiment).name;
    expFolder = strcat(experimentPath, experimentFolder, relativeFolderPath);
    cd(expFolder);
    
    % list special cases here:
    if strcmp(experimentFolder, '171213') || strcmp(experimentFolder, '180201')
        parseBars_4_repetitions()
    elseif strcmp(experimentFolder, '181115')
        disp '181115 so far is just ignored';
    else
        
        % export traces from the .h5 file
        traces = hdf5read('TracesData.h5', '/MovingBars/patterns');
        load('f0.mat', 'F0');
        load('onOffTyping.mat', 'isOff');

        % as we do not have a steady interval to use as F0, we will use the mean F0 from the Euler Stim experiment.
        avgF0 = mean(F0, 2);
        normBarTraces = (traces - avgF0) ./ avgF0;
        
        % band pass filtering
        filteredBarTraces = filterTrace(normBarTraces, barsImagingFreq);

        % we split the trace in 48 time bins, corresponding to the 48 moving bars
        [nTraces, ~] = size(filteredBarTraces);
        barResponses = zeros(nTraces, round(nStepsBarResp), nBars);
        for iBar = 1:nBars
            
            % we apply different offsets for ON and OFF cells, as their
            % responses have different timings
            tStep_init_OFF_CELLS = offset_OFF_CELLS + round((iBar - 1) * nStepsBarResp +1);
            tStep__end_OFF_CELLS  = tStep_init_OFF_CELLS + round(nStepsBarResp) - 1;
            
            tStep_init_ON_CELLS = offset_ON_CELLS + round((iBar - 1) * nStepsBarResp +1);
            tStep__end_ON_CELLS  = tStep_init_ON_CELLS + round(nStepsBarResp) - 1;
            
            barResponses(isOff, :, iBar) = filteredBarTraces(isOff, tStep_init_OFF_CELLS : tStep__end_OFF_CELLS);
            barResponses(not(isOff), :, iBar) = filteredBarTraces(not(isOff), tStep_init_ON_CELLS : tStep__end_ON_CELLS);
            
        end     
        
        % Average among repetitions
        barResponsesSorted = barResponses(:, :, dirMapping);
        barResponsesByDirections = reshape(barResponsesSorted, [nTraces, round(nStepsBarResp), nRepetitions, nDirections]);
        avgBarResponses = squeeze(median(barResponsesByDirections, 3));
        peaks = max(max(abs(avgBarResponses), [], 2), [], 3);
        avgBarResponses = avgBarResponses ./ peaks;
        
        % compute direction selectivity
        [osK, osAngle, dsK, dsAngle, dirModules] = directionSelectivity(barDirections, avgBarResponses);
        directions = barDirections;
        
        save('barResponses.mat', 'normBarTraces', 'filteredBarTraces', 'barResponses', 'barResponsesSorted',  'avgBarResponses');
        save('dirSelectivity.mat', 'osK', 'osAngle', 'dsK', 'dsAngle', 'dirModules', 'directions');    
    end
end
cd(strcat(projectPath(), '/Code/Matlab_processing/Processing'));