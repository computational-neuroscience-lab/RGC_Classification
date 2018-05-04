function doClassification()

loadDataset()

% CLUSTERING PARAMETERS
pcaTraces = {eulerResponsesMatrix, stepResponsesMatrix, eulerResponsesMatrix};
pcaNumComponents = [10, 10, 10];
nMaxClusters = [20, 8];

% INITIALIZE TABLES
nCells = numel(cellsLabels);

% Initialize structure to store the type code of each cell
clustersTable = struct( 'Experiment', {cellsLabels.experiment}, ...
                        'N', {cellsLabels.N}, ...
                        'Type', cell(1, nCells), ...
                        'Prob', cell(1, nCells)  );
            
% Initialize structure with all the different Principal Component Reductions for each cells
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

% typesIndexes = {ONs, or(OFFs, or(ON_OFFs, OTHERS)), ONLY_BARS, NO_RESP, NO_AVAIL};
% typesNames = ["ON", "OTHER", "ONLY-BARS", "NO-RESP", "NO_AVAIL"];

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

% Keep track of all classes and subclasses
Classification.sub = {}; 

% do PCA on the whole dataset
% this is also needed to project the high level classes in a common
% feature space
datasetLogical = 0;
for iClass = 1:numel(classesIndexes)
    datasetLogical = or(classesIndexes{iClass}, datasetLogical);
end

pca_trace1 = pcaTraces{1};
pca_lvl1 = doPca(pca_trace1(datasetLogical, :), pcaNumComponents(1));

datasetIndexes = find(datasetLogical);
for iDataset = 1:length(datasetIndexes)
    PCAs(datasetIndexes(iDataset)).lvl1 = pca_lvl1(iDataset, :);
end
    
% recursively cluster
for nClass_lvl1 = 1:numel(classesIndexes)
    indexesClass_lvl1 = find(classesIndexes{nClass_lvl1});
    
    % Update class labels
    class_lvl1.name = strcat(classesNames{nClass_lvl1}, ".");
    class_lvl1.sub = {};
    Classification.sub = [Classification.sub, class_lvl1];
    
     % do PCA for each macrotype independently
    pca_trace2 = pcaTraces{2};
    pca_lvl2 = doPca(pca_trace2(indexesClass_lvl1, :), pcaNumComponents(2));
    
    % do Clustering inside each macrotype
    try
        [classMapping_lvl2, probs_lvl2, numClass_lvl2] = gmClustering(pca_lvl2, nMaxClusters(1));

         % fill the table
        for iCell1 = 1:length(indexesClass_lvl1)
            PCAs(indexesClass_lvl1(iCell1)).lvl2 = pca_lvl2(iCell1, :);  

            % update the cluster label for each cell in the results table
            clustersTable(indexesClass_lvl1(iCell1)).Type = strcat(clustersTable(indexesClass_lvl1(iCell1)).Type, num2str(classMapping_lvl2(iCell1)), ".");
            clustersTable(indexesClass_lvl1(iCell1)).Prob = [clustersTable(indexesClass_lvl1(iCell1)).Prob, probs_lvl2(iCell1)];
        end    

        % inside each cluster, refine once more
        for nClass_lvl2 = 1:numClass_lvl2
            indexesClass_lvl2 = indexesClass_lvl1(classMapping_lvl2 == nClass_lvl2);

            % Update class labels
            subclass2.name = strcat(Classification.sub{nClass_lvl1}.name, num2str(nClass_lvl2), ".");
            subclass2.sub = {};
            Classification.sub{nClass_lvl1}.sub = [Classification.sub{nClass_lvl1}.sub, subclass2];

            % do PCA for each macrotype independently
            pca_trace3 = pcaTraces{3};
            pca_lvl3 = doPca(pca_trace3(indexesClass_lvl2, :), pcaNumComponents(3));

            % do Clustering inside each cluster
            try
                [classMapping_lvl3, probs_lvl3, numClass_lvl3] = gmClustering(pca_lvl3, nMaxClusters(2));

                 % fill the table
                for iCell2 = 1:length(indexesClass_lvl2)

                    PCAs(indexesClass_lvl2(iCell2)).lvl3 = pca_lvl3(iCell2, :);

                    % update the cluster label for each cell in the results table
                    clustersTable(indexesClass_lvl2(iCell2)).Type = strcat(clustersTable(indexesClass_lvl2(iCell2)).Type, num2str(classMapping_lvl3(iCell2)), ".");
                    clustersTable(indexesClass_lvl2(iCell2)).Prob = [clustersTable(indexesClass_lvl2(iCell2)).Prob, probs_lvl3(iCell2)];
                end 
                
                % Update class labels
                for nClass_lvl3 = 1:numClass_lvl3
                    subclass3.name = strcat(Classification.sub{nClass_lvl1}.sub{nClass_lvl2}.name, num2str(nClass_lvl3), ".");
                    Classification.sub{nClass_lvl1}.sub{nClass_lvl2}.sub = [Classification.sub{nClass_lvl1}.sub{nClass_lvl2}.sub, subclass3];
                end
            catch
            end
        end
    catch
    end
end

save(getDatasetMat, 'clustersTable', 'PCAs', 'Classification', '-append');