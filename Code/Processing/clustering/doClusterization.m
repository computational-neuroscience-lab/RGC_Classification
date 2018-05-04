function [clusteringIndexes, clusterProbs, numClusters] = doClusterization(X, nMaxClusters)

nReplicates = 50;

% Gaussian Mixture Fit 
infoCrit = zeros(1, nMaxClusters);
gmdCandidates = cell(1, nMaxClusters);
for k = 1:nMaxClusters
    gmdCandidates{k} = fitgmdist(X, k, 'CovarianceType', 'diagonal', 'Replicates', nReplicates, 'RegularizationValue', 0.00001);
    infoCrit(k)= gmdCandidates{k}.BIC;
end

[~, numClusters] = min(infoCrit);
gmdBest = gmdCandidates{numClusters};

% Clusterization
[clusteringIndexes, ~, P, ] = cluster(gmdBest, X);
clusterProbs = max(P, [], 2);

