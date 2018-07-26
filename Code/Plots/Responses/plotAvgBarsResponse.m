function length = plotAvgBarsResponse(expID, idCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
load(getBarsStimulus(expID))

barsRelativePath = '/traces/barResponses.mat';
barsPath = strcat(experimentsPath, expID, barsRelativePath);
load(barsPath, 'avgBarResponses', 'qualityIndexBars');

offCliff_ts = round(timeOffset_OffCells * freqCalciumImaging);
onCliff_ts = round(timeOffset_OnCells * freqCalciumImaging);

[~, length, nDirections] = size(avgBarResponses);
hold on
for iDirections = 1:nDirections
    plot(avgBarResponses(idCell, :, iDirections));
end
plot([onCliff_ts onCliff_ts], [-1, 1], 'k:');
plot([offCliff_ts offCliff_ts], [-1, 1], 'k:');

hold off
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);

yticks([-1 0 1])
xticks([0, length/2, length]);
xticklabels([0, length/2, length] / freqCalciumImaging);

title(strcat('Normalized Bars Response (QI = ', num2str(qualityIndexBars(idCell)), ')'));