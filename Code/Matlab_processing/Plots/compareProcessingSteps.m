close all,

load(strcat(projectPath(), '/Experiments/171211/traces/eulerResponses.mat'));
load(strcat(projectPath(), '/Experiments/171211/traces/barResponses.mat'));  
traces = hdf5read(strcat(projectPath(), '/Experiments/171211/traces/TracesData.h5'), '/EulerStim/patterns');

[nCells, nSteps, nResponses] = size(barResponsesSorted);
nRepetitions = nResponses / 8;
nFigures = 5;
nPlots = 5;

for iFigure = 1:nFigures

   figure;
    for iPlots = 1:nPlots
        iCell = iPlots + (iFigure-1)*nPlots;
        barFullResponsesSorted = reshape(barResponsesSorted, [nCells, nSteps*nResponses]);
        barFullResponses = reshape(barResponses, [nCells, nSteps*nResponses]);

        subplot(nPlots, 2, (iPlots-1)*2 + 1 )
        plot(barFullResponses(iCell, :));
        xlim([0  nSteps*nResponses])

        hold on
        filtered = filterTrace(barFullResponses(iCell, :), 7.83);
        plot(filtered);
        hold off

        subplot(nPlots, 2, iPlots * 2)
        plot(barFullResponsesSorted(iCell, :));
        xlim([0  nSteps*nResponses])

        hold on
        for i = 1: nSteps*nRepetitions : nSteps*nResponses
            y1=get(gca,'ylim');
            plot([i i],y1, 'r-.');
        end
        hold off
    end

    ss = get(0,'screensize');
    width = ss(3);
    height = ss(4);

    vert = 800;
    horz = 1600;

    set(gcf,'Position',[(width/2)-horz/2, (height/2)-vert/2, horz, vert]);

end



[~, nSteps, ~] = size(eulerNormResponses);
nPlots = 5;
nFigures = 5;

stdResponses = std(eulerNormResponses, 0, 3);
sigma = mean(stdResponses, 2) * 2;

for iFigure = 1:nFigures

    figure;
    for iPlot = 1:nPlots
        
        iCell = iPlot + (iFigure-1)*nPlots;
    
        subplot(nPlots, 1, iPlot)
        plot(eulerNormResponses(iCell, :, 1), 'r');
        hold on;
        filtered = NLmeansfilter(eulerNormResponses(iCell, :, 1), 10, 5, sigma(iCell));
        plot(filtered, 'LineWidth', 1);
        xlim([0 nSteps])

    end
end



