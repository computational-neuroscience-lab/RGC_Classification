function class = recClassification(name, indexesClass, n)

global nIterations;
global traceMatrices;
global nPcaComponents;
global nMaxClusters;
global sizeMinClusters;

global clustersTable;
global PCAs;

class.name = name;

% Principal Components Reduction
traceMatrix = traceMatrices{n};
pca = doPca(traceMatrix(indexesClass, :), nPcaComponents(n));

try
    % Clusterize
    [classMapping, probs, numClass] = gmClustering(pca, nMaxClusters(n));

    % Update the PCA and clusters tables
    for iCell = 1:length(indexesClass)
        pcalvl = strcat("lvl", num2str(n + 1));
        PCAs(indexesClass(iCell)).(pcalvl) = pca(iCell, :);  
        clustersTable(indexesClass(iCell)).Type = strcat(clustersTable(indexesClass(iCell)).Type, num2str(classMapping(iCell)), ".");
        clustersTable(indexesClass(iCell)).Prob = [clustersTable(indexesClass(iCell)).Prob, probs(iCell)];
    end
    
    % Recursive Classification on sub-clusters
    if n < nIterations
        
        subclasses = {};
        for nClass = 1:numClass
            sizeCluster = length(indexesClass(classMapping == nClass));
            if sizeCluster >= sizeMinClusters
                subclassName = strcat(name, num2str(nClass), ".");
                subclassIndexes = indexesClass(classMapping == nClass);                
                subclass = recClassification(subclassName, subclassIndexes, n + 1);
                subclasses = [subclasses, subclass];
            end
            
        end
        
        if numel(subclasses) > 0
            class.sub = subclasses;
        end
    end

catch
end

