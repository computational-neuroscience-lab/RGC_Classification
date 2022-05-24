function [names] = getSubclasses(typeId)
names = [];

if  endsWith(typeId, ".")
    typeId = extractBefore(typeId, strlength(typeId));
end

load(getDatasetMat, 'classTree');

if strcmp(typeId, "")
    classes = cell2mat(classTree.sub);
    if ~isempty(classes) 
        names = [classes.name];
        return
    else
        error("Class tree is empty")
    end
end
            
typeSplit = strsplit(typeId, ".");
type = "";

for iType = 1:numel(typeSplit)
    type =  strcat(type, typeSplit(iType), ".");
    
    
    classes = cell2mat(classTree.sub);
    if ~isempty(classes) 
        subNames = [classes.name];
    else
        error("Class not existent (tree stops before)")
    end

    nClass = find(strcmp(type, subNames));
    if ~isempty(nClass) 
        classTree = classTree.sub{nClass};
    else
        error("Class not existent (tree does not include sublabel)")
    end
end

classes = cell2mat(classTree.sub);
if ~isempty(classes) 
    names = [classes.name];
end