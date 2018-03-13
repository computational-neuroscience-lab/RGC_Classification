function plotCell(expID, nCell)

figure('Name', strcat('Cell #', int2str(nCell),' from experiment_', expID));

% Plot Cell ROI
subplot(4,4,[1,5])
plotCellROI(expID, nCell);

% plot Euler Responses
subplot(4,4,[2,3]);   
lsE = plotAvgEulerResponse(expID, nCell);

subplot(4,4,[9,10,11]);     
lrE = plotRawTrace(expID, nCell, 'EulerStim');

% plot Euler Stimuli
subplot(4,4,[6,7]);     
plotSingleEulerStim();
xlim([0 lsE])

subplot(4,4,[13,14,15]);     
plotEulerStim();
xlim([0 lrE])
title('Full Euler stimulus');

% plot Bar Responses
subplot(4,4,[4,8]);
titleBars = 'Bars Avg Responses';
try
    plotAvgBarsResponse(expID, nCell);
catch
    titleBars = strcat(titleBars, ' - NOT AVAILABLE'); 
end
title(titleBars);

subplot(4,4,[12,16]);
titleDS = 'Direction Selectivity';
try
    plotDirectionSelectivity(expID, nCell);
catch
    titleDS = strcat(titleDS, ' - NOT AVAILABLE'); 
end
title(titleDS)

% set figure position and scaling
ss = get(0,'screensize');
width = ss(3);
height = ss(4);

vert = 800;
horz = 1600;

set(gcf,'Position',[(width/2)-horz/2, (height/2)-vert/2, horz, vert]);




