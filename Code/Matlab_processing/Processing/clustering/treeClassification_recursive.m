function class = treeClassification_recursive(name, indexesClass, n)

global nIterations;
global nPcaComponents;
global features;
global nMaxBranchings;

global clustersTable;
global PCAs;

% Check if the current class is admissible as a leaf cluster
if clusterIsAdmissible(indexesClass)
    class.name = name;
    class.sub = {};
else
    class = [];
end

% Check if the current class will be pruned
if ~clusterIsAdmissible(indexesClass) && (~clusterIsSplittable(indexesClass) || n > nIterations)
    for iCell = 1:length(indexesClass)
        className = clustersTable(indexesClass(iCell)).Type;
        className = strcat(extractBefore(className, strlength(className)), "_PRUNED.");
        clustersTable(indexesClass(iCell)).Type = className;
    end
end
        
% Check if it is possible to split again the current cluster
if ~clusterIsSplittable(indexesClass) || n > nIterations   
    return
end

% Principal Components Reduction
traceMatrix = features{n};
pca = doPca(traceMatrix(indexesClass, :), nPcaComponents(n));

% Clusterize
try
    [classMapping, probs, numClass] = doClusterization(pca, nMaxBranchings(n));
catch
    fprintf("Clusterization of cluster %s failed\n", name)
    return;
end

% Update the PCA and clusters tables
for iCell = 1:length(indexesClass)
    pcaLvl = strcat("lvl", num2str(n + 1));
    PCAs(indexesClass(iCell)).(pcaLvl) = pca(iCell, :);  
    clustersTable(indexesClass(iCell)).Type = strcat(clustersTable(indexesClass(iCell)).Type, num2str(classMapping(iCell)), ".");
    clustersTable(indexesClass(iCell)).Prob = [clustersTable(indexesClass(iCell)).Prob, probs(iCell)];
end

% Recursive Classification on sub-clusters
subclasses = {};
for nClass = 1:numClass
    subclassName = strcat(name, num2str(nClass), ".");
    subclassIndexes = indexesClass(classMapping == nClass);                
    subclass = treeClassification_recursive(subclassName, subclassIndexes, n + 1);
    if length(subclass) > 0
        subclasses = [subclasses, subclass];
    end
end

% If there are some subclasses, add them and return the whole subtree
if numel(subclasses) > 0
    class.name = name;
    class.sub = subclasses;
end
        
