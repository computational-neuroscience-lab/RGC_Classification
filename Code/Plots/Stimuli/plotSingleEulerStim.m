function plotSingleEulerStim()

eulerStimMat = strcat(projectPath(), '/VisualStimulations/EulerStim.mat');
load(eulerStimMat, 'eulerStim_single');
plot(eulerStim_single);
l = length(eulerStim_single);
xlim([0 l])
set(gca,'xtick',[])
set(gca,'ytick',[])
title('Single Euler stimulus');
