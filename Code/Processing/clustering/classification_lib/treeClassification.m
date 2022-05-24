function [clustersTable, classTree, PCAs] = treeClassification(cellsTable, traces, labels2cells, labelsToCluster)

% ALGORITHM FOR UNSUPERVISED RECURSIVE CLASSIFICATION OF RGCs
% The population of cells is subdivided in clusters recursively.
% Preliminary classifications are accepted as input.
% Each of the provided classes of cells is subdivided recursively.

% If no prelinimary classes are provided, all cells will be considered
% and clustered together.

% If preliminary classes are provided, only cells belonging to the
% preliminary classes will be clustered, and each class will be clustered
% independently.

% traces: the cell responses [2d mat: cell_num x time_step]
% labels2cells: the prelinimary classes [map: label 2 logical indices]
% labelsToCluster: the classes NOT PRESENT in this list are considered
% FINAL and hence will not be subclustered [list: labels]

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
refFeatures = traces;
refNPcaComponents = 10;

% recursive classification
nIterations = 3;
features = {traces, traces, traces};
nPcaComponents = [10, 10, 10];
nMaxBranchings = [16, 12, 8];

% admissibility check
admissibleMinSize = 4;
admissibleMaxSTD = 0.25;

% splittability check
splittableMinSize = 12;
splittableMinSTD = 0.2;


%-----------------------------STRUCTURES---------------------------------%

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
            
            
%------------------------INITIALIZE TABLES-------------------------------%

if ~exist('labels2cells','var')
    labels2cells = containers.Map;
    labels2cells('') = logical(len(traces));
end

if ~exist('labelsToCluster','var')
    labelsToCluster = keys(labels2cells);
end

% Initialize the clusters Table
for label_struct = keys(labels2cells)
    label = cell2mat(label_struct);
    cIndices = find(labels2cells(label));
    cName = string(label);
    for cIndex = cIndices
        clustersTable(cIndex).Type = strcat(cName, ".");
    end
end

% Choose which types to clusterize
nClasses = numel(labelsToCluster);
classesLogicals = cell(nClasses, 1);
for i = 1:nClasses
    label = cell2mat(labelsToCluster(i));
    classLogicals = labels2cells(label);
    classesLogicals(i) = {classLogicals};
end

%-------------------------DO CLUSTERING----------------------------------%

% Do PCA on the whole dataset.
% This is only needed to project the high level classes in a common feature space
datasetLogical = 0;
for iClass = 1:numel(classesLogicals)
    datasetLogical = or(classesLogicals{iClass}, datasetLogical);
end
datasetIndexes = find(datasetLogical);

refPCA = doPca(refFeatures(datasetLogical, :), refNPcaComponents);
for iDataset = 1:length(datasetIndexes)
    PCAs(datasetIndexes(iDataset)).lvl1 = refPCA(iDataset, :);
end


% RECURSIVE CLUSTERIZATION

if nIterations > 0
    classTree.sub = {};
    for iClass = 1:numel(classesLogicals)
        classIndices = find(classesLogicals{iClass});
        subclass = treeClassification_recursive(strcat(labelsToCluster(iClass), "."), classIndices, 1);
        if length(subclass) > 0
            classTree.sub = [classTree.sub, subclass];
        end
    end
end