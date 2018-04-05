function [subclassesNames] = getSubclasses(typeId)
load(getDatasetMat, 'Classification');

if  endsWith(typeId, ".")
    typeId = extractBefore(typeId, strlength(typeId));
end
typeSplit = strsplit(typeId, ".");

try
    if ~strcmp(typeSplit, "")
        type = "";
        for iType = 1:numel(typeSplit)
            type =  strcat(type, typeSplit(iType), ".");
            subclasses = cell2mat(Classification.sub);

            subclassesNames = [subclasses.name];

            nSubclass = find(strcmp(type, subclassesNames));
            Classification = Classification.sub{nSubclass};
        end
    end

    subclasses = cell2mat(Classification.sub);
    subclassesNames = [subclasses.name];

catch
    subclassesNames = [];
end