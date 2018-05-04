function prunedTypes = getPrunedClasses(typeId)

load(getDatasetMat(), 'clustersTable');

if ~exist('typeId','var')
    typeId = "";
elseif  not(endsWith(typeId, "."))
    typeId = strcat(typeId, ".");
end

typeCodes = [clustersTable.Type];
logicals = and(startsWith(typeCodes, typeId), endsWith(typeCodes, "_PRUNED."));
prunedTypes = unique([clustersTable(logicals).Type]);
