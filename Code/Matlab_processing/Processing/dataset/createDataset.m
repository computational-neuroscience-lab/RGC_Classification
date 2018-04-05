function createDataset(datasetId)

try
    load(strcat(projectPath(), '/Datasets/listOfDatasets.mat'), 'datasets');
catch
    datasets = struct('name', {}, 'path', {});
end

if sum(strcmp(datasetId, [datasets.name])) > 0
    fprintf("WARNING, Dataset with this name already exists. Impossible to create dataset\n");
	return
end

datasets(numel(dataset) + 1).name = datasetId;
datasets(numel(dataset) + 1).path = strcat("Datasets/", datasetId, "Matrix.mat");
activeDataset = datasets(numel(dataset) + 1);

try
    save(strcat(projectPath(), '/Datasets/listOfDatasets.mat'), 'activeDataset', 'datasets', '-append');
catch
    save(strcat(projectPath(), '/Datasets/listOfDatasets.mat'), 'activeDataset', 'datasets');
end


