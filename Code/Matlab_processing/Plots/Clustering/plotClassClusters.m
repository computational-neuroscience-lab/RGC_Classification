function plotClassClusters(typeIDs, pcaSpaceID)

if ~exist('pcaSpaceID','var')
    % assume all the classes are from the same pca space
    pcaSpaceID = getPCASpace(typeIDs(1));
end
 
load(getDatasetMat, 'PCAs');
pcaSpace = {PCAs.(pcaSpaceID)};


text = strcat("Cell Clusters in 3 principal components from ", pcaSpaceID, " space");
figure('Name', text);

for typeId = typeIDs
    cellsIndexes = classIndexes(typeId);
    cellsPCs = cell2mat(pcaSpace(cellsIndexes)');
    
    scatter3(cellsPCs(:, 1), cellsPCs(:, 2), cellsPCs(:, 3), 'filled');
    hold on   
end    
 hold off
 legend(typeIDs)
 title(text);