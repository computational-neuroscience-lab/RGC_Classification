load(getDatasetMat, 'cellsTable', 'tracesMat')
[preliminaryClasses, typesToCluster] = preliminaryClassification(cellsTable);
[clustersTable, classTree, PCAs] = treeClassification(cellsTable, tracesMat, preliminaryClasses, typesToCluster);
save(getDatasetMat, 'clustersTable', 'PCAs', 'classTree', '-append');