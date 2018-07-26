function barsStimulus = getBarsStimulus(experimentFolder)

stimH5File = strcat(projectPath, '/Experiments/', experimentFolder, '/traces/TracesData.h5');
barsStimType = h5readatt(stimH5File, '/MovingBars/patterns', 'subtype');

% Load Stimulus Data
if strcmp(barsStimType, '')
    barsStimMat = '/VisualStimulations/MovingBars.mat';
else
    barsStimMat = strcat('/VisualStimulations/MovingBars_', barsStimType, '.mat');
end
barsStimulus = strcat(projectPath(), barsStimMat);