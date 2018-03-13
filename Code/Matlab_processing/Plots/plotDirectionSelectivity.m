function plotDirectionSelectivity(expID, idCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
dsRelativePath = '/traces/dirSelectivity.mat';
dsPath = strcat(experimentsPath, expID, dsRelativePath);
load(dsPath, 'osK', 'osAngle', 'dsK', 'dsAngle', 'dirModules', 'directions');    

plotAngles = [directions, directions(1)];
plotMods = [dirModules(idCell,:), dirModules(idCell, 1)];

if  min(plotMods) < 0 
    plotMods = plotMods -  min(plotMods);
end

polarplot(plotAngles, plotMods, 'LineWidth', 1.5);
hold on

polarplot([dsAngle(idCell), dsAngle(idCell) + pi], [dsK(idCell), dsK(idCell)], 'g-.', 'LineWidth', 1.8);
polarplot([0, osAngle(idCell)], [0, osK(idCell)], 'r', 'LineWidth', 1.8);
hold off

txt1 = strcat('K_d = ', num2str(dsK(idCell)), '   \alpha_d = ', num2str(dsAngle(idCell)), 'rads');
txt2 = strcat('K_o = ', num2str(osK(idCell)), '   \alpha_o = ', num2str(osAngle(idCell)), 'rads');
text(5/4*pi,1.2,{txt1, txt2});

thetaticks(0:45:315);
thetaticklabels([]);
rticklabels([]);
rlim([0 1])
rticks([0, 0.25, .5, .75, 1.0])




