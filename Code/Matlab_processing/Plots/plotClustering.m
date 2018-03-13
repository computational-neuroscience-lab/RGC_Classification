function plotClustering()
close all
datasetMat = strcat(projectPath(), '/Dataset/dataSetMatrix.mat');
load(datasetMat, 'clusters', 'X');

figure('Name', 'Clusters in 3 principal components space');
legendTxt = {};
[numClusters, ~] = size(clusters);
for iCluster = 1:numClusters
    [nElem, ~] = size(clusters{iCluster}.cells);
    idxs = 1:min(nElem, 20);
    scatter3(X(clusters{iCluster}.cells(idxs), 1), X(clusters{iCluster}.cells(idxs), 2), X(clusters{iCluster}.cells(idxs), 3), 'filled');
    hold on
    
    legendTxt = [legendTxt, strcat('cl', int2str(iCluster))];
end    
 hold off
 legend(legendTxt)
 title('Clusters in 3 principal components space');
 
 cd('/home/fran_tr/AllOptical/Dataset');
 savefig(gcf, 'Clusters')