function changeDataset(datasetId)

load(strcat(projectPath(), '/Datasets/listOfDatasets.mat'), 'datasets');
try
    load(strcat(projectPath(), '/Datasets/listOfDatasets.mat'), 'datasets');
catch
    fprintf("ERROR, no datasets available. Create one with \'createDataset\' function");
end

index = find(strcmp(datasetId, [datasets.name]));
if length(index) == 0
    fprintf("WARNING, Datasets does not exist. Impossible to change dataset\n");
	return
end

activeDataset = datasets(index);
save(strcat(projectPath(), '/Datasets/listOfDatasets.mat'), 'activeDataset', '-append');


