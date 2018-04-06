function length = plotAvgBarsSplit(expID, idCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
barsRelativePath = '/traces/barResponses.mat';
barsPath = strcat(experimentsPath, expID, barsRelativePath);
load(barsPath, 'avgBarResponses', 'qualityIndexBars');

[~, length, nDirections] = size(avgBarResponses);
% hold on
for iDirections = 1:nDirections
    figure
    plot(avgBarResponses(idCell, :, iDirections), 'k', 'LineWidth', 5);
    title = strcat("Direction = ", num2str(iDirections));

    xlim([0 length])
    ylim([-1.2 1.2])
    pbaspect([1 1 1]);

    yticks([])
    xticks([0, length/2, length]);
    xticklabels([0, length/2, length] / freqCalciumImaging);

    saveas(gcf, title,'png')
end
hold off