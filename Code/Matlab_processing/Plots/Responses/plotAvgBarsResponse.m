function length = plotAvgBarsResponse(expID, idCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
simtulusParamsPath = strcat(projectPath(), '/VisualStimulations/MovingBars.mat');
load(simtulusParamsPath)
barsRelativePath = '/traces/barResponses.mat';
barsPath = strcat(experimentsPath, expID, barsRelativePath);
load(barsPath, 'avgBarResponses', 'qualityIndexBars');

[~, length, nDirections] = size(avgBarResponses);
hold on
for iDirections = 1:nDirections
    plot(avgBarResponses(idCell, :, iDirections));
end
hold off
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);

yticks([-1 0 1])
xticks([0, length/2, length]);
xticklabels([0, length/2, length] / freqCalciumImaging);

title(strcat('Normalized Bars Response (QI = ', num2str(qualityIndexBars(idCell)), ')'));