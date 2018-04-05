function cellsIndexes = classIndexes(typeId)

load(getDatasetMat(), 'clustersTable');

if  not(endsWith(typeId, "."))
    typeId = strcat(typeId, ".");
end

typeCodes = [clustersTable.Type];
cellsIndexes = startsWith(typeCodes, typeId);
