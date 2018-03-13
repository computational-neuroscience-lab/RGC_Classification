function printClusters()

datasetMat = strcat(projectPath(), '/Dataset/dataSetMatrix.mat');
load(datasetMat, 'cellsLabels', 'clusters');

nCols = 3;
nRows = 8;

% Plot
close all
cd(strcat(projectPath(), '/Dataset/Clusters'));

for iCluster = 1:numel(clusters)
    titleStr = strcat('Cluster #', int2str(iCluster));
    figure('Name', titleStr);
    for iColPlot = 1:nCols
        for iRowPlot = 1:nRows
            iPlot = iRowPlot + nRows * (iColPlot-1);
            [nCells, ~] =  size(clusters{iCluster}.cells);
            if iPlot <= nCells
                subplot(nRows, nCols, iPlot)
                
                iCell = clusters{iCluster}.cells(iPlot);
                iProb = clusters{iCluster}.probs(iPlot);
                iExp = cellsLabels(iCell).experiment;
                iID = cellsLabels(iCell).nCell;

                plotAvgEulerResponse(iExp, iID);
                plotTitle = strcat('Cell #', int2str(iID),' from Exp. ', iExp, ' (P=', num2str(iProb), ')');
                title(plotTitle);
            end
        end
    end
    ss = get(0,'screensize');
    width = ss(3);
    height = ss(4);
    vert = 800;
    horz = 1600;
    set(gcf,'Position',[(width/2)-horz/2, (height/2)-vert/2, horz, vert]);
    saveas(gcf, titleStr,'png')
end
