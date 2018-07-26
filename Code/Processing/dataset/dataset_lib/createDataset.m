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

nRow = numel(datasets) + 1;
datasets(nRow).name = datasetId;
datasets(nRow).path = strcat("Datasets/", datasetId, "Matrix.mat");
activeDataset = datasets(nRow);

try
    save(strcat(projectPath(), '/Datasets/listOfDatasets.mat'), 'activeDataset', 'datasets', '-append');
catch
    save(strcat(projectPath(), '/Datasets/listOfDatasets.mat'), 'activeDataset', 'datasets');
end


