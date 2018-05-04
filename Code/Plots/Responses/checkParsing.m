function checkParsing(expID)
close all,

load(strcat(projectPath(), '/Experiments/', expID, '/traces/eulerResponses.mat'));
load(strcat(projectPath(), '/Experiments/', expID, '/traces/barResponses.mat'));  
traces = hdf5read(strcat(projectPath(), '/Experiments/', expID, '/traces/TracesData.h5'), '/EulerStim/patterns');


% Plot Filtering in Bars Responses

[nCells, nSteps, nResponses] = size(barResponsesSorted);
nRepetitions = nResponses / 8;
nFigures = 5;
nPlots = 5;

for iFigure = 1:nFigures

    figure('Name', 'filtered Bars Responses ');
    for iPlot = 1:nPlots
        iCell = iPlot + (iFigure-1)*nPlots;

        barFullResponses = reshape(barResponses, [nCells, nSteps*nResponses]);
        barFullResponsesFiltered = reshape(barResponsesFiltered, [nCells, nSteps*nResponses]);
        barFullResponsesSorted = reshape(barResponsesSorted, [nCells, nSteps*nResponses]);

        subplot(nPlots, 2, (iPlot-1)*2 + 1 )
        plot(barFullResponses(iCell, :));
        hold on
        plot(barFullResponsesFiltered(iCell, :));
        hold off
                
        xlim([0  nSteps*nResponses])
        legend({'Raw Trace', 'Filtered Trace'}); 
        
        if iPlot == 1
            title('Bars Responses sorted by time sequence');
        end

        subplot(nPlots, 2, iPlot * 2)
        plot(barFullResponsesSorted(iCell, :));

        hold on
        for i = 1: nSteps*nRepetitions : nSteps*nResponses
            y1=get(gca,'ylim');
            plot([i i],y1, 'r-.');
        end
        hold off
        
        xlim([0  nSteps*nResponses])
        legend({'Filtered Trace'}); 
               
        if iPlot == 1
            title('Bars Responses sorted by direction');
        end

    end

    ss = get(0,'screensize');
    width = ss(3);
    height = ss(4);

    vert = 800;
    horz = 1600;

    set(gcf,'Position',[(width/2)-horz/2, (height/2)-vert/2, horz, vert]);

end

% Plot Denoise in Euler Responses

nSteps = size(eulerNormResponses, 2);
nPlots = 5;
nFigures = 5;

stdResponses = std(eulerNormResponses, 0, 3);
sigma = mean(stdResponses, 2) * 2;

% for iFigure = 1:nFigures
% 
%     figure('Name', 'densoised Euler Responses ');
%     for iPlot = 1:nPlots
%         
%         iCell = iPlot + (iFigure-1)*nPlots;
%     
%         subplot(nPlots, 1, iPlot)
%         plot(eulerNormResponses(iCell, :, 1));
%         hold on;
%         filtered = NLmeansfilter(eulerNormResponses(iCell, :, 1), 10, 5, sigma(iCell));
%         plot(filtered, 'LineWidth', 1.5);
%         xlim([0 nSteps])
%         legend({'Raw Trace', 'Denoised Trace'}); 
%         
% 
%         ss = get(0,'screensize');
%         width = ss(3);
%         height = ss(4);
% 
%         vert = 800;
%         horz = 1600;
% 
%         set(gcf,'Position',[(width/2)-horz/2, (height/2)-vert/2, horz, vert]);
% 
%     end
% end



