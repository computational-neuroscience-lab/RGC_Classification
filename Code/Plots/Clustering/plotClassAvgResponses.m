function plotClassAvgResponses(typeIDs, titleText)


if ~exist('titleText','var')
    titleText = "Average Class Responses";
end
 
nTypes = length(typeIDs);
nCols = 2;
nRows = 4;
iClass = 0; 

while iClass < nTypes
    figure('Name', titleText)
    for iColPlot = 1:nCols
        for iRowPlot = 1:nRows
            iClass = iClass + 1;
            if iClass <= nTypes
                iPlot = mod(iClass - 1, nCols*nRows) + 1;
                subplot(nRows, nCols, iPlot)
                indexes = classIndexes(typeIDs(iClass));
                avgSTD = plotAvgResponse(indexes);
                title(strcat("Class ", typeIDs(iClass), " (size = ", num2str(sum(indexes)), ", avgSTD = ", num2str(avgSTD), ")"));
            end
        end
    end
    ss = get(0,'screensize');
    width = ss(3);
    height = ss(4);
    vert = 800;
    horz = 1600;
    set(gcf,'Position',[(width/2)-horz/2, (height/2)-vert/2, horz, vert]);
end
