function length = plotSingleEulerStim()

eulerStimMat = strcat(projectPath(), '/VisualStimulations/EulerStim.mat');
load(eulerStimMat, 'singleEulerStim');
plot(singleEulerStim);
singleEulerStimSize = size(singleEulerStim);
length = singleEulerStimSize(1);
xlim([0 length])
title('Single Euler stimulus');