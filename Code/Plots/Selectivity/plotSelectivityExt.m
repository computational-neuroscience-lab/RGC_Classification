function plotSelectivityExt(expID, idCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
barsRelativePath = '/traces/barResponses.mat';
dsRelativePath = '/traces/dirSelectivity.mat';

dsPath = strcat(experimentsPath, expID, dsRelativePath);
barsPath = strcat(experimentsPath, expID, barsRelativePath);

load(barsPath, 'avgBarResponses', 'qualityIndexBars');
load(dsPath, 'osK', 'osAngle', 'dsK', 'dsAngle', 'dirModules', 'directions');    

[~, length, nDirections] = size(avgBarResponses);

subplot(3,3,1);
plot([0,length], [0,0], 'r');
hold on
plot(avgBarResponses(idCell, :, 4), 'k', 'LineWidth', 3);
t1 = strcat("Direction = ", num2str(4));
title(t1);
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);

subplot(3,3,2);
plot([0,length], [0,0], 'r');
hold on
plot(avgBarResponses(idCell, :, 3), 'k', 'LineWidth', 3);
t2 = strcat("Direction = ", num2str(3));
title(t2)
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);

subplot(3,3,3);
plot([0,length], [0,0], 'r');
hold on
plot(avgBarResponses(idCell, :, 2), 'k', 'LineWidth', 3);
t3 = strcat("Direction = ", num2str(2));
title(t3)
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);

subplot(3,3,4);
plot([0,length], [0,0], 'r');
hold on
plot(avgBarResponses(idCell, :, 5), 'k', 'LineWidth', 3);
t4 = strcat("Direction = ", num2str(5));
title(t4)
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);

subplot(3,3,5); 
plotAngles = [directions, directions(1)];
plotMods = [dirModules(idCell,:), dirModules(idCell, 1)];

polarplot(plotAngles, plotMods, 'k', 'LineWidth', 3);
hold on
polarplot([0, dsAngle(idCell)], [0, dsK(idCell)], 'r', 'LineWidth', 2.5);
hold off

thetaticks(0:45:315);
thetaticklabels([]);
rticklabels([]);
rlim([0 1])
rticks([0, 0.25, .5, .75, 1.0])

subplot(3,3,6);
plot([0,length], [0,0], 'r');
hold on
plot(avgBarResponses(idCell, :, 1), 'k', 'LineWidth', 3);
t6 = strcat("Direction = ", num2str(1));
title(t6)
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);

subplot(3,3,7);
plot([0,length], [0,0], 'r');
hold on
plot(avgBarResponses(idCell, :, 6), 'k', 'LineWidth', 3);
t7 = strcat("Direction = ", num2str(6));
title(t7)
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);

subplot(3,3,8);
plot([0,length], [0,0], 'r');
hold on
plot(avgBarResponses(idCell, :, 7), 'k', 'LineWidth', 3);
t8 = strcat("Direction = ", num2str(7));
title(t8)
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);

subplot(3,3,9);
plot([0,length], [0,0], 'r');
hold on
plot(avgBarResponses(idCell, :, 8), 'k', 'LineWidth', 3);
t9 = strcat("Direction = ", num2str(8));
title(t9)
xlim([0 length])
ylim([-1.2 1.2])
pbaspect([1 1 1]);
xticks([]);
yticks([]);


