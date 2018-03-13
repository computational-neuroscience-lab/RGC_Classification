function gmClustering()

datasetMat = strcat(projectPath(), '/Dataset/dataSetMatrix.mat');
load(datasetMat, 'eulerResponsesMatrix', 'cellsLabels');

nMaxClusters = 50;
nPrincipalComponents = 10;

% Principal Components Reduction
[nCells, nDimensions] = size(eulerResponsesMatrix);
meanER = mean(eulerResponsesMatrix, 1);
normER = eulerResponsesMatrix - ones(nCells,1) * meanER;
[~, ~, coeff] = svd(normER);
X = normER * coeff(:, 1:nPrincipalComponents);

% Gaussian Mixture Fit 
infoCrit = zeros(1, nMaxClusters);
gmdCandidates = cell(1, nMaxClusters);
for k = 1:nMaxClusters
    gmdCandidates{k} = fitgmdist(X, k, 'CovarianceType', 'diagonal', 'Replicates', 25, 'RegularizationValue', 0.00001);
    infoCrit(k)= gmdCandidates{k}.BIC;
end

[~, numClusters] = min(infoCrit);
gmdBest = gmdCandidates{numClusters};

% Clusterization
[clusterIndexes, ~, P, ] = cluster(gmdBest, X);
clusters = cell(numClusters, 1);
for iCluster = 1:numClusters

    probs = P(clusterIndexes == iCluster, iCluster);
    cellIDs = find(clusterIndexes == iCluster);
    
    % sort by probability of appartainance
    [clusters{iCluster}.probs, sortingIndexes] = sort(probs, 'descend');
    clusters{iCluster}.cells = cellIDs(sortingIndexes);

end

save(datasetMat, 'clusters', 'X', '-append');

plotClustering();
printClusters();
    
    

