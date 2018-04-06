function isAdmissible = clusterIsAdmissible(indexesClass)

global refFeatures;
global admissibleMinSize;
global admissibleMaxSTD;

sizeClass = length(indexesClass);
classFeatures = refFeatures(indexesClass, :);
avgSTD = mean(std(classFeatures, [], 1));

isAdmissible = and(sizeClass > admissibleMinSize, avgSTD < admissibleMaxSTD);