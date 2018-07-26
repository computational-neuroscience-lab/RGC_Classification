function plotSelectivityExt90(expID, idCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
barsRelativePath = '/traces/barResponses.mat';
dsRelativePath = '/traces/dirSelectivity.mat';

dsPath = strcat(experimentsPath, expID, dsRelativePath);
barsPath = strcat(experimentsPath, expID, barsRelativePath);

load(barsPath, 'avgBarResponses', 'qualityIndexBars');
load(dsPath, 'osK', 'osAngle', 'dsK', 'dsAngle', 'dirModules', 'directions');    
load(getBarsStimulus(expID))

length = size(avgBarResponses, 2);

offCliff_ts = round(timeOffset_OffCells * freqCalciumImaging);
onCliff_ts = round(timeOffset_OnCells * freqCalciumImaging);

subplot(3,3,1);
plot([0,length], [0,0], 'r');
hold on
plot([onCliff_ts onCliff_ts], [-1, 1], 'r:');
plot([offCliff_ts offCliff_ts], [-1, 1], 'r:');

plot(avgBarResponses(idCell, :, 6), 'k', 'LineWidth', 3);
% t1 = strcat("Direction = ", num2str(4));
% title(t1);
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);
box off
axis off

subplot(3,3,2);
plot([0,length], [0,0], 'r');
hold on
plot([onCliff_ts onCliff_ts], [-1, 1], 'r:');
plot([offCliff_ts offCliff_ts], [-1, 1], 'r:');

plot(avgBarResponses(idCell, :, 5), 'k', 'LineWidth', 3);
% t2 = strcat("Direction = ", num2str(3));
% title(t2)
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);
box off
axis off

subplot(3,3,3);
plot([0,length], [0,0], 'r');
hold on
plot([onCliff_ts onCliff_ts], [-1, 1], 'r:');
plot([offCliff_ts offCliff_ts], [-1, 1], 'r:');

plot(avgBarResponses(idCell, :, 4), 'k', 'LineWidth', 3);
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);
box off
axis off

subplot(3,3,4);
plot([0,length], [0,0], 'r');
hold on
plot([onCliff_ts onCliff_ts], [-1, 1], 'r:');
plot([offCliff_ts offCliff_ts], [-1, 1], 'r:');

plot(avgBarResponses(idCell, :, 7), 'k', 'LineWidth', 3);
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);
box off
axis off

subplot(3,3,5); 

plotAngles = [directions, directions(1)] - pi/2;
plotMods = [dirModules(idCell,:), dirModules(idCell, 1)];
polarplot(plotAngles, plotMods, 'k', 'LineWidth', 3);
hold on
polarplot([0, dsAngle(idCell) - pi/2], [0, dsK(idCell)], 'r', 'LineWidth', 2.5);
hold off

thetaticks(0:45:315);
thetaticklabels([]);
rticklabels([]);
rlim([0 1])
rticks([0, 0.25, .5, .75, 1.0])
box off

subplot(3,3,6);
plot([0,length], [0,0], 'r');
hold on
plot([onCliff_ts onCliff_ts], [-1, 1], 'r:');
plot([offCliff_ts offCliff_ts], [-1, 1], 'r:');

plot(avgBarResponses(idCell, :, 3), 'k', 'LineWidth', 3);
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);
box off
axis off

subplot(3,3,7);
plot([0,length], [0,0], 'r');
hold on
plot([onCliff_ts onCliff_ts], [-1, 1], 'r:');
plot([offCliff_ts offCliff_ts], [-1, 1], 'r:');

plot(avgBarResponses(idCell, :, 8), 'k', 'LineWidth', 3);
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);
box off
axis off

subplot(3,3,8);
plot([0,length], [0,0], 'r');
hold on
plot(avgBarResponses(idCell, :, 1), 'k', 'LineWidth', 3);
plot([onCliff_ts onCliff_ts], [-1, 1], 'r:');
plot([offCliff_ts offCliff_ts], [-1, 1], 'r:');

xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);
box off
axis off

subplot(3,3,9);
plot([0,length], [0,0], 'r');
hold on
plot([onCliff_ts onCliff_ts], [-1, 1], 'r:');
plot([offCliff_ts offCliff_ts], [-1, 1], 'r:');

plot(avgBarResponses(idCell, :, 2), 'k', 'LineWidth', 3);
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);

box off
axis off

