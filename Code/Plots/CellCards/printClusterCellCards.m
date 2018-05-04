function printClusterCellCards()
close all;

datasetMat = strcat(projectPath(), '/Dataset/dataSetMatrix.mat');
load(datasetMat, 'clusters', 'cellsLabels');


for iCluster = 6 : numel(clusters)
    clusterId = strcat('cl', int2str(iCluster));
    clusterFolder = strcat(projectPath(), '/Dataset/', clusterId);
    try
        rmdir(clusterFolder,'s')
    end
    mkdir(clusterFolder);
    cd(clusterFolder);
    
    [nCells, ~] = size(clusters{iCluster}.cells);
    for iCell = 1 : nCells
        iLabel = clusters{iCluster}.cells(iCell);
        iProb = clusters{iCluster}.probs(iCell);

        plotCell(cellsLabels(iLabel).experiment, cellsLabels(iLabel).nCell);

        title = strcat('Exp', cellsLabels(iLabel).experiment, '_Cell#', int2str(cellsLabels(iLabel).nCell), ' (P=', num2str(iProb), ')');
        saveas(gcf, title,'png')
        close;
    end
end
cd(strcat(projectPath(), '/Code/Matlab_processing'));
        