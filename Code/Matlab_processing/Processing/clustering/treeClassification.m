function treeClassification()

loadDataset()

% CLUSTERING PARAMETERS

% preliminary clustering
preTraceMatrix = eulerResponsesMatrix;
prePcaComponents = 10;

% recursive clustering
global nIterations;
global traceMatrices;
global nPcaComponents;
global nMaxClusters;
global sizeMinClusters;

nIterations = 2;
traceMatrices = {stepResponsesMatrix, eulerResponsesMatrix};
nPcaComponents = [10, 10];
nMaxClusters = [25, 25];
sizeMinClusters = 5;

% INITIALIZE TABLES
nCells = numel(cellsLabels);

% Initialize structure to store the type code of each cell
global clustersTable;
clustersTable = struct( 'Experiment', {cellsLabels.experiment}, ...
                        'N', {cellsLabels.N}, ...
                        'Type', cell(1, nCells), ...
                        'Prob', cell(1, nCells)  );
            
% Initialize structure with all the different Principal Component Reductions for each cells
global PCAs;
PCAs = struct(  'lvl1', cell(nCells,1), ...
                'lvl2', cell(nCells,1), ...
                'lvl3', cell(nCells,1));

% DEFINE CELLS CATEGORIES

% Responsive Cells
VALIDS = [cellsLabels(:).eulerQT] == 1;
ONLY_BARS = and([cellsLabels(:).eulerQT] == 0, [cellsLabels(:).barsQT] == 1);
NO_RESP = and([cellsLabels(:).eulerQT] == 0, [cellsLabels(:).barsQT] == 0);
NO_AVAIL = and(~VALIDS, and(~ONLY_BARS, ~NO_RESP));

% among VALIDS, 4 functional macrotypes
ONs = and(and([cellsLabels(:).ON] == 1, [cellsLabels(:).OFF] == 0), VALIDS);
OFFs = and(and([cellsLabels(:).OFF] == 1, [cellsLabels(:).ON] == 0), VALIDS);
ON_OFFs = and(and([cellsLabels(:).ON] == 1, [cellsLabels(:).OFF] == 1), VALIDS);
OTHERS = and(and([cellsLabels(:).ON] == 0, [cellsLabels(:).OFF] == 0), VALIDS);

% Direction Selectivity
DSs = [cellsLabels(:).DS] == 1;


% SELECT CLASSES FOR CLUSTERING

% define on which classes to do the clustering:
typesIndexes = {ONs, OFFs, ON_OFFs, OTHERS, ONLY_BARS, NO_RESP, NO_AVAIL};
typesNames = ["ON", "OFF", "ON-OFF", "OTHER", "ONLY-BARS", "NO-RESP", "NO_AVAIL"];

% typesIndexes = {VALIDS, ONLY_BARS, NO_RESP, NO_AVAIL};
% typesNames = ["VALID", "ONLY-BARS", "NO-RESP", "NO_AVAIL"];

for i = 1:numel(typesNames)
    indexesClass_lvl2 = find(typesIndexes{i});
    cName = typesNames(i);
    for cIndex = indexesClass_lvl2
        clustersTable(cIndex).Type = strcat(clustersTable(cIndex).Type, cName, ".");
        clustersTable(cIndex).Prob = [clustersTable(cIndex).Prob, 1];
    end
end

% Add DS as a subtype to Direction Selective cells
dsIndexes = find(DSs);
dsName = "DS";
for cIndex = dsIndexes
    clustersTable(cIndex).Type = strcat(clustersTable(cIndex).Type, dsName, ".");
    clustersTable(cIndex).Prob = [clustersTable(cIndex).Prob, 1];
end

% Then remove DS cells from the clustering dataset
for iClass = 1:numel(typesIndexes)
    typesIndexes{iClass} = and(typesIndexes{iClass}, ~DSs);
end

% Remove the ONLY_BARS and NO_RESP classes from the clastering dataset
classesIndexes = typesIndexes(1:end-3);
classesNames = typesNames(1:end-3);


% DO CLUSTERING

% Do PCA on the whole dataset.
% This is only needed to project the 
% high level classes in a common feature space
datasetLogical = 0;
for iClass = 1:numel(classesIndexes)
    datasetLogical = or(classesIndexes{iClass}, datasetLogical);
end
datasetIndexes = find(datasetLogical);

prePCA = doPca(preTraceMatrix(datasetLogical, :), prePcaComponents);
for iDataset = 1:length(datasetIndexes)
    PCAs(datasetIndexes(iDataset)).lvl1 = prePCA(iDataset, :);
end


% RECURSIVE CLUSTERIZATION
if nIterations > 0
    Classification.sub = {};
    for iClass = 1:numel(classesIndexes)
        classIndexes = find(classesIndexes{iClass});
        sizeCluster = length(classIndexes);
        if sizeCluster >= sizeMinClusters
            subclass = recClassification(strcat(classesNames(iClass), "."), classIndexes, 1);
            Classification.sub = [Classification.sub, subclass];
        end
    end
end

save(getDatasetMat, 'clustersTable', 'PCAs', 'Classification', '-append');