function plotCell(expID, nCell)

figure('Name', strcat('Cell #', int2str(nCell),' from experiment_', expID));

% Plot Cell ROI
subplot(4,4,[1,5])
plotCellROI(expID, nCell);

% On-Off typing
load(getDatasetMat, 'clustersTable')
try
    idCell = find(and([clustersTable.Experiment] == expID, [clustersTable.N] == nCell));
    label = clustersTable(idCell).Type;
catch
    label = 'Label Unavailable';
end

title(label);

% plot Euler Responses
subplot(4,4,[2,3]);   
plotAvgEulerResponse(expID, nCell);

subplot(4,4,[9,10,11]);     
plotRawEulerTrace(expID, nCell);

% plot Euler Stimuli
subplot(4,4,[6,7]);     
plotSingleEulerStim();

subplot(4,4,[13,14,15]);     
plotEulerStim();
title('Full Euler stimulus');

% plot Bar Responses
subplot(4,4,[4,8]);
try
    plotAvgBarsResponse(expID, nCell);
catch
    title('Bars Avg Responses - NOT AVAILABLE'); 
end

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




