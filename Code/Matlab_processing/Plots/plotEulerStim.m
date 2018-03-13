function length = plotEulerStim()
experimentsPath = strcat(projectPath(), '/Experiments/');
load(strcat(projectPath(), '/VisualStimulations/EulerStim.mat'), 'resampledEulerStim');
plot(resampledEulerStim);
eulerStimSize = size(resampledEulerStim);
length = eulerStimSize(1);
xlim([0 length])
title('Full Euler stimulus');