function length = plotAvgBarsResponse(expID, idCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
barsRelativePath = '/traces/barResponses.mat';
barsPath = strcat(experimentsPath, expID, barsRelativePath);
load(barsPath, 'avgBarResponses');

[~, length, nDirections] = size(avgBarResponses);
hold on
for iDirections = 1:nDirections
    plot(avgBarResponses(idCell, :, iDirections));
end
hold off
xlim([0 length])