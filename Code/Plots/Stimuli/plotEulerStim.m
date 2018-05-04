function plotEulerStim()
load(strcat(projectPath(), '/VisualStimulations/EulerStim.mat'), 'eulerStim');
plot(eulerStim);
l = length(eulerStim);
xlim([0 l])
set(gca,'xtick',[])
set(gca,'ytick',[])
title('Full Euler stimulus');