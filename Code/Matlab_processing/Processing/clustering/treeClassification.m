function treeClassification()

loadDataset()

% global parameters
global refFeatures;

global nIterations;
global nPcaComponents;
global features;
global nMaxBranchings;

global admissibleMinSize;
global admissibleMaxSTD;

global splittableMinSize;
global splittableMinSTD;

% global structures
global clustersTable;
global PCAs;


%-------------------------- PARAMETERS ----------------------------------%

% preliminary classification
refFeatures = eulerResponsesMatrix;
refNPcaComponents = 10;

% recursive classification
nIterations = 3;
features = {eulerResponsesMatrix, eulerResponsesMatrix, eulerResponsesMatrix};
nPcaComponents = [10, 10, 10];
nMaxBranchings = [16, 12, 8];

% admissibility check
admissibleMinSize = 4;
admissibleMaxSTD = 0.25;

% splittability check
splittableMinSize = 12;
splittableMinSTD = 0.2;

%------------------------------------------------------------------------%


% INITIALIZE TABLES
nCells = numel(cellsTable);

% Initialize structure to store the type code of each cell
clustersTable = struct( 'Experiment', {cellsTable.experiment}, ...
                        'N', {cellsTable.N}, ...
                        'Type', cell(1, nCells), ...
                        'Prob', cell(1, nCells)  );
            
% Initialize structure with all the different Principal Component Reductions for each cells
PCAs = struct(  'lvl1', cell(nCells,1), ...
                'lvl2', cell(nCells,1), ...
                'lvl3', cell(nCells,1));

            
% DEFINE CELLS CATEGORIES

% Responsive Cells
VALIDS =    [cellsTable(:).eulerQT] == 1;
ONLY_BARS = and([cellsTable(:).eulerQT] == 0, [cellsTable(:).barsQT] == 1);
NO_RESP =   and([cellsTable(:).eulerQT] == 0, [cellsTable(:).barsQT] == 0);
NO_AVAIL =  and(~VALIDS, and(~ONLY_BARS, ~NO_RESP));

% among VALIDS, 4 functional macrotypes
ONs =       and(and([cellsTable(:).ON] == 1, [cellsTable(:).OFF] == 0), VALIDS);
OFFs =      and(and([cellsTable(:).ON] == 0, [cellsTable(:).OFF] == 1), VALIDS);
ON_OFFs =   and(and([cellsTable(:).ON] == 1, [cellsTable(:).OFF] == 1), VALIDS);
OTHERS =    and(and([cellsTable(:).ON] == 0, [cellsTable(:).OFF] == 0), VALIDS);

% Direction Selectivity
DSs = [cellsTable(:).DS] == 1;


% SELECT CLASSES FOR CLUSTERING
typesIndexes = {ONs, OFFs, ON_OFFs, OTHERS, ONLY_BARS, NO_RESP, NO_AVAIL};
typesNames = ["ON", "OFF", "ON-OFF", "OTHER", "ONLY-BARS", "NO-RESP", "NO_AVAIL"];

for i = 1:numel(typesNames)
    indexesClass_lvl2 = find(typesIndexes{i});
    cName = typesNames(i);
    for cIndex = indexesClass_lvl2
        clustersTable(cIndex).Type = strcat(clustersTable(cIndex).Type, cName, ".");
        clustersTable(cIndex).Prob = [clustersTable(cIndex).Prob, 1];
    end
end

% Add the DS label to Direction Selective Cells
dsIndexes = find(DSs);
dsName = "DS";
for cIndex = dsIndexes
    clustersTable(cIndex).Type = strcat(clustersTable(cIndex).Type, dsName, ".");
    clustersTable(cIndex).Prob = [clustersTable(cIndex).Prob, 1];
end

% Remove DS cells from the dataset for the clustering
for iClass = 1:numel(typesIndexes)
    typesIndexes{iClass} = and(typesIndexes{iClass}, ~DSs);
end

% Remove the ONLY_BARS, NO_RESP and NO_AVAIL cells from the dataset for the clustering
classesIndexes = typesIndexes(1:end-3);
classesNames = typesNames(1:end-3);


% DO CLUSTERING

% Do PCA on the whole dataset.
% This is only needed to project the high level classes in a common feature space
datasetLogical = 0;
for iClass = 1:numel(classesIndexes)
    datasetLogical = or(classesIndexes{iClass}, datasetLogical);
end
datasetIndexes = find(datasetLogical);

refPCA = doPca(refFeatures(datasetLogical, :), refNPcaComponents);
for iDataset = 1:length(datasetIndexes)
    PCAs(datasetIndexes(iDataset)).lvl1 = refPCA(iDataset, :);
end


% RECURSIVE CLUSTERIZATION
if nIterations > 0
    classTree.sub = {};
    for iClass = 1:numel(classesIndexes)
        classIndexes = find(classesIndexes{iClass});
        subclass = treeClassification_recursive(strcat(classesNames(iClass), "."), classIndexes, 1);
        if length(subclass) > 0
            classTree.sub = [classTree.sub, subclass];
        end
    end
end

save(getDatasetMat, 'clustersTable', 'PCAs', 'classTree', '-append');