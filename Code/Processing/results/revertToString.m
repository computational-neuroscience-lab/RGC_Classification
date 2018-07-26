function revertToString()

loadDataset
for i = 1:numel(cellsTable)
    cellsTable(i).experiment = string(cellsTable(i).experiment);
end

for i = 1:numel(classesTable)
    classesTable(i).name = string(classesTable(i).name);
end

for i = 1:numel(clustersTable)
    clustersTable(i).Experiment = string(clustersTable(i).Experiment);
    clustersTable(i).Type = string(clustersTable(i).Type);
end
save('finalMatrix.mat', 'clustersTable', 'cellsTable', 'classesTable');