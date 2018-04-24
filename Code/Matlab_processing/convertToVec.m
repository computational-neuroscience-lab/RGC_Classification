function convertToVec()

loadDataset
for i = 1:numel(cellsTable)
    cellsTable(i).experiment = char(cellsTable(i).experiment);
end

for i = 1:numel(classesTable)
    classesTable(i).name = char(classesTable(i).name);
end

for i = 1:numel(clustersTable)
    clustersTable(i).Experiment = char(clustersTable(i).Experiment);
    clustersTable(i).Type = char(clustersTable(i).Type);
end
save('finalMatrix.mat', 'clustersTable', 'cellsTable', 'classesTable');