function mat = getDatasetMat()
try
    load(strcat(projectPath(), '/Datasets/listOfDatasets.mat'), 'activeDataset');
    mat = strcat(projectPath(), '/', activeDataset.path);
catch
    fprintf("ERROR, no datasets available. Create one with \'createDataset\' function");
end


